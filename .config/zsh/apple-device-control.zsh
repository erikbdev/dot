#!/usr/bin/env zsh

# Build and run the current iOS/iPadOS Xcode project on a simulator or device.
# This file is sourced by ~/.zshrc and can also be invoked directly.

_adc_usage() {
  cat <<'USAGE'
Usage:
  apple-device-control devices [--json]
  apple-device-control build [options]
  apple-device-control run [options]
  apple-device-control watch [options]

Commands:
  devices        List available iPhone/iPad simulators and paired devices.
  build          Build the detected project for the selected destination.
  run            Build, install, and launch the app.
  watch          Run once, then rebuild, reinstall, and relaunch on file changes.
                 If no device is active, watch boots the only available simulator.

Options for build, run, and watch:
  -p, --project PATH       Project bundle or directory (default: current working directory)
  -s, --scheme NAME        Xcode scheme (optional; automatically selected when omitted)
  -d, --device NAME|UDID   Exact device name or UDID; see `devices`
      --runtime VERSION    Filter simulators by runtime (for example, 18.6 or 'iOS 18.6')
  -c, --configuration NAME Build configuration (default: Debug)
      --bundle-id ID       Select the app product by bundle identifier
      --derived-data PATH  Override the DerivedData directory
      --interval SECONDS   Watch polling interval (default: 1)
  -h, --help               Show this help

Device selection:
  Set APPLE_DEVICE_ID, or pass --device. Without either, exactly one booted
  simulator or connected physical device must be available for build and run.
  Watch can instead select and boot the only available simulator when no device
  is active. Use --device when more than one simulator is available.
  Use --runtime to select a simulator runtime, alone or together with --device.
  By default, run and watch use a separate DerivedData folder per simulator;
  build uses a shared project/scheme folder. --derived-data or
  APPLE_DEVICE_DERIVED_DATA overrides either.

Project defaults:
  APPLE_DEVICE_PROJECT, APPLE_DEVICE_SCHEME, APPLE_DEVICE_CONFIGURATION,
  APPLE_DEVICE_ID, APPLE_DEVICE_RUNTIME, APPLE_DEVICE_BUNDLE_ID,
  APPLE_DEVICE_DERIVED_DATA, and APPLE_DEVICE_WATCH_INTERVAL can set defaults
  for interactive or agent use.

Requirements:
  Xcode command-line tools and jq. Build output uses xcbeautify when installed.

Examples:
  apple-device-control devices
  apple-device-control run --device 'iPad Air (iOS 18.6)'
  apple-device-control watch --device 'iPhone 17 Pro' --runtime 18.6
  apple-device-control watch --device 548D3222-A10D-47C4-AB84-DCDD7E3733F7
  zsh ~/.config/zsh/apple-device-control.zsh run --project App.xcworkspace --scheme App --device 'iPad Air (iOS 18.6)'
USAGE
}

_adc_error() {
  print -u2 -r -- "apple-device-control: $*"
}

# OSC 0 sets the terminal title; OSC 9;4 requests an indeterminate progress icon.
_adc_terminal_status() {
  emulate -L zsh
  local label="$1"
  local state="${2:-busy}"
  local title_sequence progress_sequence

  [[ -t 1 ]] || return 0

  title_sequence=$'\e]0;'"$label"$'\a'
  case "$state" in
    busy) progress_sequence=$'\e]9;4;3;0\a' ;;
    error) progress_sequence=$'\e]9;4;2;100\a' ;;
    *) progress_sequence=$'\e]9;4;0;0\a' ;;
  esac
  print -n -- "$title_sequence$progress_sequence"
}

_adc_require_tools() {
  local tool
  local -a missing
  missing=()

  for tool in xcodebuild xcrun jq; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
  done

  if (( ${#missing} > 0 )); then
    _adc_error "required command(s) not found: ${(j:, :)missing}"
    return 1
  fi
}

_adc_collect_devices_json() {
  local simulator_json physical_json

  simulator_json="$(xcrun simctl list devices available --json)" || {
    _adc_error 'could not read the available Simulator devices'
    return 1
  }

  physical_json="$(xcrun devicectl -q list devices --omit-deprecated-fields-in-json --json-output - 2>/dev/null)" || \
    physical_json='{"result":{"devices":[]}}'

  jq -n \
    --argjson simulators "$simulator_json" \
    --argjson physical "$physical_json" '
      [
        $simulators.devices
        | to_entries[]
        | .key as $runtime
        | .value[]
        | select($runtime | contains("iOS"))
        | select(.isAvailable != false)
        | {
            id: .udid,
            name: .name,
            kind: "simulator",
            state: .state,
            platform: "iOS",
            runtime: (
              $runtime
              | sub("^com\\.apple\\.CoreSimulator\\.SimRuntime\\."; "")
              | sub("^iOS-"; "iOS ")
              | gsub("-"; ".")
            )
          }
      ]
      +
      [
        $physical.result.devices[]?
        | select(.properties.hardware.platform == "iOS")
        | select(.properties.hardware.reality == "physical")
        | {
            id: (.properties.hardware.udid // .identifier),
            name: (.properties.state.name // .deviceProperties.name // .identifier),
            kind: "device",
            state: (
              if .properties.connection.state == "connected" then "connected"
              elif .properties.connection.pairingState == "paired" then "paired"
              else (.properties.connection.state // "unknown") end
            ),
            platform: "iOS"
          }
      ]
      | sort_by(.kind, .name, .id)
    '
}

_adc_devices() {
  emulate -L zsh
  local json=0
  local arg

  for arg in "$@"; do
    case "$arg" in
      --json) json=1 ;;
      -h|--help) _adc_usage; return 0 ;;
      *) _adc_error "unknown devices option: $arg"; return 2 ;;
    esac
  done

  _adc_require_tools || return 1

  local data
  data="$(_adc_collect_devices_json)" || return 1

  if (( json )); then
    print -r -- "$data"
    return 0
  fi

  print -r -- 'TYPE       STATE       RUNTIME          NAME                                      UDID'
  local kind state runtime name identifier
  jq -r '.[] | "\(.kind)\t\(.state)\t\(.runtime // "-")\t\(.name)\t\(.id)"' <<< "$data" |
    while IFS=$'\t' read -r kind state runtime name identifier; do
      printf '%-10s %-11s %-16s %-41s %s\n' "$kind" "$state" "$runtime" "$name" "$identifier"
    done
}

_adc_resolve_device() {
  emulate -L zsh
  local selector="$1"
  local allow_shutdown_simulator="${2:-0}"
  local requested_runtime="${3:-}"
  local devices matches count

  devices="$(_adc_collect_devices_json)" || return 1

  if [[ -z "$selector" || "$selector" == auto ]]; then
    if [[ -n "$requested_runtime" ]]; then
      matches="$(jq -c '[.[] | select(.kind == "simulator")]' <<< "$devices")" || return 1
    else
      matches="$(jq -c '[.[] | select((.kind == "simulator" and .state == "Booted") or (.kind == "device" and .state == "connected"))]' <<< "$devices")" || return 1
      if [[ "$allow_shutdown_simulator" == 1 ]] && [[ "$(jq 'length' <<< "$matches")" == 0 ]]; then
        matches="$(jq -c '[.[] | select(.kind == "simulator")]' <<< "$devices")" || return 1
      fi
    fi
  elif [[ "$selector" == booted ]]; then
    matches="$(jq -c '[.[] | select(.kind == "simulator" and .state == "Booted")]' <<< "$devices")" || return 1
  else
    matches="$(jq -c --arg selector "$selector" '[.[] | select(.id == $selector or .name == $selector)]' <<< "$devices")" || return 1
  fi

  if [[ -n "$requested_runtime" ]]; then
    matches="$(jq -c --arg runtime "$requested_runtime" '
      def normalized_runtime:
        ascii_downcase
        | sub("^com\\.apple\\.coresimulator\\.simruntime\\."; "")
        | sub("^ios([ -])?"; "")
        | gsub("-"; ".")
        | gsub("[^0-9.]"; "");
      [.[] | select((.kind == "simulator") and (((.runtime // "") | normalized_runtime) == ($runtime | normalized_runtime)))]
    ' <<< "$matches")" || return 1
  fi

  count="$(jq 'length' <<< "$matches")" || return 1
  if (( count == 0 )); then
    if [[ -n "$requested_runtime" ]]; then
      if [[ -n "$selector" && "$selector" != auto ]]; then
        _adc_error "no simulator matches '$selector' with runtime '$requested_runtime'"
      else
        _adc_error "no available iOS simulator matches runtime '$requested_runtime'"
      fi
    elif [[ -n "$selector" && "$selector" != auto ]]; then
      _adc_error "no iOS simulator or physical device matches '$selector'"
    elif [[ "$allow_shutdown_simulator" == 1 ]]; then
      _adc_error 'no available iOS simulator or connected physical device; connect a device or install an available simulator'
    else
      _adc_error 'no unambiguous booted simulator or connected device; pass --device or set APPLE_DEVICE_ID'
    fi
    return 1
  fi

  if (( count > 1 )); then
    _adc_error 'multiple devices match; choose one by UDID with --device or narrow simulator choices with --runtime:'
    jq -r '.[] | "  \(.name) [\(.kind), \(.state), runtime=\(.runtime // "-")]  \(.id)"' <<< "$matches" >&2
    return 1
  fi

  jq -c '.[0]' <<< "$matches"
}

_adc_find_project() {
  emulate -L zsh
  local requested="${1:-$PWD}"
  local -a workspaces projects

  requested="${requested:A}"
  if [[ ! -d "$requested" ]]; then
    _adc_error "project path does not exist or is not a directory: $requested"
    return 1
  fi

  if [[ "$requested" == *.xcodeproj || "$requested" == *.xcworkspace ]]; then
    print -r -- "$requested"
    return 0
  fi

  workspaces=("$requested"/*.xcworkspace(N))
  projects=("$requested"/*.xcodeproj(N))

  if (( ${#workspaces} > 1 )); then
    _adc_error "multiple workspaces found in $requested; pass --project with a workspace"
    printf '  %s\n' "${workspaces[@]}" >&2
    return 1
  fi

  if (( ${#workspaces} == 1 )); then
    print -r -- "${workspaces[1]}"
    return 0
  fi

  if (( ${#projects} > 1 )); then
    _adc_error "multiple projects found in $requested; pass --project with a project"
    printf '  %s\n' "${projects[@]}" >&2
    return 1
  fi

  if (( ${#projects} == 1 )); then
    print -r -- "${projects[1]}"
    return 0
  fi

  _adc_error "no .xcworkspace or .xcodeproj found in $requested; pass --project"
  return 1
}

_adc_resolve_scheme() {
  emulate -L zsh
  local requested="$1"
  local project_name="$2"
  local container_kind="$3"
  shift 3
  local -a container_args=("$@")
  local listing scheme_text target_text candidate selected
  local -a schemes targets

  listing="$(xcodebuild -list -json "${container_args[@]}")" || {
    _adc_error 'xcodebuild could not list schemes for this project'
    return 1
  }

  scheme_text="$(jq -r '.project.schemes[]?, .workspace.schemes[]?' <<< "$listing")" || {
    _adc_error 'could not read the project scheme list from xcodebuild'
    return 1
  }
  schemes=()
  [[ -n "$scheme_text" ]] && schemes=("${(@f)scheme_text}")

  if [[ -n "$requested" ]]; then
    for candidate in "${schemes[@]}"; do
      [[ "$candidate" == "$requested" ]] && { printf 'scheme\t%s\n' "$candidate"; return 0; }
    done
    _adc_error "scheme '$requested' was not listed by xcodebuild"
  else
    for candidate in "${schemes[@]}"; do
      [[ "$candidate" == "$project_name" ]] && { printf 'scheme\t%s\n' "$candidate"; return 0; }
    done

    if (( ${#schemes} == 1 )); then
      printf 'scheme\t%s\n' "${schemes[1]}"
      return 0
    elif (( ${#schemes} > 1 )); then
      selected="${schemes[1]}"
      print -u2 -r -- "apple-device-control: no --scheme provided; defaulting to '$selected' (pass --scheme to override)"
      printf 'scheme\t%s\n' "$selected"
      return 0
    fi
  fi

  if (( ${#schemes} > 0 )); then
    print -u2 -r -- 'Available schemes:'
    printf '  %s\n' "${schemes[@]}" >&2
    return 1
  fi

  if [[ "$container_kind" == project && -z "$requested" ]]; then
    target_text="$(jq -r '.project.targets[]?' <<< "$listing")" || {
      _adc_error 'could not read project targets from xcodebuild'
      return 1
    }
    targets=()
    [[ -n "$target_text" ]] && targets=("${(@f)target_text}")

    if (( ${#targets} == 0 )); then
      _adc_error 'xcodebuild did not report schemes or targets for this project'
      return 1
    fi

    for candidate in "${targets[@]}"; do
      [[ "$candidate" == "$project_name" ]] && { printf 'target\t%s\n' "$candidate"; return 0; }
    done

    selected="${targets[1]}"
    if (( ${#targets} > 1 )); then
      print -u2 -r -- "apple-device-control: no scheme found; defaulting to target '$selected'"
    fi
    printf 'target\t%s\n' "$selected"
    return 0
  fi

  _adc_error 'this workspace has no schemes; add or share a scheme in Xcode'
  return 1
}

_adc_project_signature() {
  emulate -L zsh
  local root="$1"

  /usr/bin/find "$root" \
    \( -type d \( \
      -name .git -o -name .build -o -name .swiftpm -o -name DerivedData -o \
      -name build -o -name Pods -o -name Carthage -o -name node_modules -o \
      -name .apple-device-control \
    \) -prune \) -o \
    \( -type f ! -name .DS_Store ! -name '*.xcuserstate' \
      -exec /usr/bin/stat -f '%i %m %c %z %N' {} + \) 2>/dev/null |
    /usr/bin/cksum
}

_adc_find_built_app() {
  emulate -L zsh
  local selector_name="$1"
  local expected_bundle_id="$2"
  local configuration="$3"
  local derived_data="$4"
  shift 4
  local -a xcode_args=("$@")
  local settings app_paths_text app bundle_id package_type
  local -a app_paths apps scheme_matches

  settings="$(xcodebuild "${xcode_args[@]}" \
    -configuration "$configuration" \
    -derivedDataPath "$derived_data" \
    -showBuildSettings)" || {
      _adc_error 'could not read the built app product path from xcodebuild'
      return 1
    }

  app_paths_text="$(print -r -- "$settings" | /usr/bin/awk '
    function flush() {
      if (product ~ /\.app$/ && dir != "") print dir "/" product
    }
    /^Build settings for action / { flush(); dir = ""; product = ""; next }
    /^[[:space:]]*TARGET_BUILD_DIR = / {
      dir = $0
      sub(/^[[:space:]]*TARGET_BUILD_DIR = /, "", dir)
      next
    }
    /^[[:space:]]*FULL_PRODUCT_NAME = / {
      product = $0
      sub(/^[[:space:]]*FULL_PRODUCT_NAME = /, "", product)
      next
    }
    END { flush() }
  ')"

  app_paths=()
  [[ -n "$app_paths_text" ]] && app_paths=("${(@f)app_paths_text}")
  apps=()

  for app in "${app_paths[@]}"; do
    [[ -d "$app" && -f "$app/Info.plist" ]] || continue
    package_type="$(/usr/libexec/PlistBuddy -c 'Print :CFBundlePackageType' "$app/Info.plist" 2>/dev/null)"
    [[ "$package_type" == APPL ]] || continue
    bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist" 2>/dev/null)"
    [[ -n "$bundle_id" ]] || continue
    if [[ -z "$expected_bundle_id" || "$bundle_id" == "$expected_bundle_id" ]]; then
      apps+=("$app")
    fi
  done

  if (( ${#apps} == 0 )); then
    if [[ -n "$expected_bundle_id" ]]; then
      _adc_error "no built .app product has bundle identifier '$expected_bundle_id'"
    else
      _adc_error 'xcodebuild completed but no built .app product was found; use --bundle-id if the selected target builds multiple apps'
    fi
    return 1
  fi

  if (( ${#apps} == 1 )); then
    print -r -- "${apps[1]}"
    return 0
  fi

  scheme_matches=()
  for app in "${apps[@]}"; do
    [[ "${app:t:r}" == "$selector_name" ]] && scheme_matches+=("$app")
  done
  if (( ${#scheme_matches} == 1 )); then
    print -r -- "${scheme_matches[1]}"
    return 0
  fi

  _adc_error 'the selected build target produced multiple apps; choose one with --bundle-id'
  for app in "${apps[@]}"; do
    bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist" 2>/dev/null)"
    print -u2 -r -- "  $bundle_id  ($app)"
  done
  return 1
}

_adc_xcodebuild() {
  emulate -L zsh
  setopt pipefail

  if command -v xcbeautify >/dev/null 2>&1; then
    NSUnbufferedIO=YES xcodebuild "$@" 2>&1 | xcbeautify
  else
    xcodebuild "$@"
  fi
}

_adc_build_or_run() {
  emulate -L zsh
  local action="$1"
  local project_override="$2"
  local requested_scheme="$3"
  local selector="$4"
  local configuration="$5"
  local requested_bundle_id="$6"
  local requested_derived_data="$7"
  local allow_shutdown_simulator="${8:-0}"
  local requested_runtime="${9:-}"

  local project_file project_type project_name selector_info selector_kind selector_name device_json
  local device_id device_name device_kind device_state device_runtime destination sdk derived_data project_hash
  local app_path bundle_id developer_dir
  local -a container_args build_selector_args build_args

  _adc_terminal_status '⏳ apple-device-control — Resolving project' busy
  project_file="$(_adc_find_project "$project_override")" || return 1
  project_name="${project_file:t:r}"
  if [[ "$project_file" == *.xcworkspace ]]; then
    container_args=(-workspace "$project_file")
    project_type=workspace
  else
    container_args=(-project "$project_file")
    project_type=project
  fi

  _adc_terminal_status '⏳ apple-device-control — Selecting scheme' busy
  selector_info="$(_adc_resolve_scheme "$requested_scheme" "$project_name" "$project_type" "${container_args[@]}")" || return 1
  selector_kind="${selector_info%%$'\t'*}"
  selector_name="${selector_info#*$'\t'}"
  _adc_terminal_status '⏳ apple-device-control — Selecting device' busy
  device_json="$(_adc_resolve_device "$selector" "$allow_shutdown_simulator" "$requested_runtime")" || return 1
  device_id="$(jq -r '.id' <<< "$device_json")"
  device_name="$(jq -r '.name' <<< "$device_json")"
  device_kind="$(jq -r '.kind' <<< "$device_json")"
  device_state="$(jq -r '.state' <<< "$device_json")"
  device_runtime="$(jq -r '.runtime // empty' <<< "$device_json")"

  if [[ "$device_kind" == simulator ]]; then
    destination="platform=iOS Simulator,id=$device_id"
  else
    destination="platform=iOS,id=$device_id"
  fi

  if [[ "$selector_kind" == scheme ]]; then
    build_selector_args=(-scheme "$selector_name" -destination "$destination")
  else
    sdk=iphoneos
    [[ "$device_kind" == simulator ]] && sdk=iphonesimulator
    build_selector_args=(-target "$selector_name" -sdk "$sdk")
  fi

  project_hash="$(print -rn -- "$project_file:$selector_kind:$selector_name" | /usr/bin/shasum -a 256 | /usr/bin/awk '{print substr($1, 1, 12)}')"
  derived_data="$requested_derived_data"
  [[ -n "$derived_data" ]] || derived_data="${APPLE_DEVICE_DERIVED_DATA:-}"
  if [[ -z "$derived_data" ]]; then
    derived_data="$HOME/Library/Developer/Xcode/DerivedData/AppleDeviceControl-$project_hash"
    if [[ "$action" == run && "$device_kind" == simulator ]]; then
      derived_data+="-$device_id"
    fi
  fi
  derived_data="${derived_data:a}"

  if [[ -n "$device_runtime" ]]; then
    print -r -- "Target: $device_name ($device_kind, $device_runtime, $device_id)"
  else
    print -r -- "Target: $device_name ($device_kind, $device_id)"
  fi
  print -r -- "DerivedData: $derived_data"
  print -r -- "Project: $project_file"
  print -r -- "${(C)selector_kind}: $selector_name ($configuration)"
  print -r -- 'Building...'

  build_args=(
    "${container_args[@]}"
    "${build_selector_args[@]}"
    -configuration "$configuration"
    -derivedDataPath "$derived_data"
    build
  )
  _adc_terminal_status "⏳ apple-device-control — Building $selector_name" busy
  _adc_xcodebuild "${build_args[@]}" || return $?

  if [[ "$action" == build ]]; then
    _adc_terminal_status '✅ apple-device-control — Build complete' idle
    print -r -- "Build complete: $derived_data"
    return 0
  fi

  _adc_terminal_status '⏳ apple-device-control — Locating built app' busy
  app_path="$(_adc_find_built_app \
    "$selector_name" \
    "$requested_bundle_id" \
    "$configuration" \
    "$derived_data" \
    "${container_args[@]}" \
    "${build_selector_args[@]}")" || return 1
  bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_path/Info.plist" 2>/dev/null)"
  if [[ -z "$bundle_id" ]]; then
    _adc_error "could not read CFBundleIdentifier from $app_path/Info.plist"
    return 1
  fi

  print -r -- "Installing $bundle_id..."
  if [[ "$device_kind" == simulator ]]; then
    if [[ "$device_state" != Booted ]]; then
      print -r -- "Booting simulator $device_name..."
      _adc_terminal_status "⏳ apple-device-control — Booting $device_name" busy
      xcrun simctl boot "$device_id" || return $?
    fi
    _adc_terminal_status "⏳ apple-device-control — Waiting for $device_name" busy
    xcrun simctl bootstatus "$device_id" -b || return $?
    developer_dir="$(xcode-select -p 2>/dev/null)"
    if [[ -n "$developer_dir" && -d "$developer_dir/Applications/Simulator.app" ]]; then
      open -a "$developer_dir/Applications/Simulator.app" --args -CurrentDeviceUDID "$device_id" >/dev/null 2>&1 || true
    fi
    xcrun simctl terminate "$device_id" "$bundle_id" >/dev/null 2>&1 || true
    _adc_terminal_status "⏳ apple-device-control — Installing on $device_name" busy
    xcrun simctl install "$device_id" "$app_path" || return $?
    _adc_terminal_status "⏳ apple-device-control — Launching on $device_name" busy
    xcrun simctl launch "$device_id" "$bundle_id" || return $?
  else
    _adc_terminal_status "⏳ apple-device-control — Installing on $device_name" busy
    xcrun devicectl device install app --device "$device_id" "$app_path" || return $?
    _adc_terminal_status "⏳ apple-device-control — Launching on $device_name" busy
    xcrun devicectl device process launch --terminate-existing --device "$device_id" "$bundle_id" || return $?
  fi

  _adc_terminal_status '✅ apple-device-control — Run complete' idle
  print -r -- "Installed and launched $bundle_id on $device_name."
}

_adc_project_command() {
  emulate -L zsh
  local action="$1"
  shift

  local project_override="${APPLE_DEVICE_PROJECT:-}"
  local requested_scheme="${APPLE_DEVICE_SCHEME:-}"
  local selector="${APPLE_DEVICE_ID:-}"
  local requested_runtime="${APPLE_DEVICE_RUNTIME:-}"
  local configuration="${APPLE_DEVICE_CONFIGURATION:-Debug}"
  local bundle_id="${APPLE_DEVICE_BUNDLE_ID:-}"
  local derived_data="${APPLE_DEVICE_DERIVED_DATA:-}"
  local interval="${APPLE_DEVICE_WATCH_INTERVAL:-1}"
  local command_status
  local help=0

  while (( $# > 0 )); do
    case "$1" in
      -p|--project)
        (( $# >= 2 )) || { _adc_error "$1 requires a path"; return 2; }
        project_override="$2"; shift 2 ;;
      --project=*) project_override="${1#*=}"; shift ;;
      -s|--scheme)
        (( $# >= 2 )) || { _adc_error "$1 requires a name"; return 2; }
        requested_scheme="$2"; shift 2 ;;
      --scheme=*) requested_scheme="${1#*=}"; shift ;;
      -d|--device)
        (( $# >= 2 )) || { _adc_error "$1 requires a name or UDID"; return 2; }
        selector="$2"; shift 2 ;;
      --device=*) selector="${1#*=}"; shift ;;
      --runtime)
        (( $# >= 2 )) || { _adc_error "$1 requires a version, such as 18.6"; return 2; }
        [[ -n "$2" ]] || { _adc_error "$1 cannot be empty"; return 2; }
        requested_runtime="$2"; shift 2 ;;
      --runtime=*)
        requested_runtime="${1#*=}"
        [[ -n "$requested_runtime" ]] || { _adc_error '--runtime cannot be empty'; return 2; }
        shift ;;
      -c|--configuration)
        (( $# >= 2 )) || { _adc_error "$1 requires a name"; return 2; }
        configuration="$2"; shift 2 ;;
      --configuration=*) configuration="${1#*=}"; shift ;;
      --bundle-id)
        (( $# >= 2 )) || { _adc_error "$1 requires an identifier"; return 2; }
        bundle_id="$2"; shift 2 ;;
      --bundle-id=*) bundle_id="${1#*=}"; shift ;;
      --derived-data)
        (( $# >= 2 )) || { _adc_error "$1 requires a path"; return 2; }
        derived_data="$2"; shift 2 ;;
      --derived-data=*) derived_data="${1#*=}"; shift ;;
      --interval|--poll-interval)
        (( $# >= 2 )) || { _adc_error "$1 requires a positive whole number of seconds"; return 2; }
        interval="$2"; shift 2 ;;
      --interval=*|--poll-interval=*) interval="${1#*=}"; shift ;;
      -h|--help) help=1; shift ;;
      --) shift; break ;;
      *) _adc_error "unknown option for $action: $1"; return 2 ;;
    esac
  done

  if (( help )); then
    _adc_usage
    return 0
  fi

  if (( $# > 0 )); then
    _adc_error "unexpected argument: $1"
    return 2
  fi

  if [[ -z "$configuration" ]]; then
    _adc_error 'configuration cannot be empty'
    return 2
  fi

  if [[ "$action" == watch ]]; then
    if [[ "$interval" != <-> ]] || (( interval < 1 )); then
      _adc_error '--interval must be a positive whole number of seconds'
      return 2
    fi
  fi

  _adc_require_tools || return 1

  local project_file project_root
  project_file="$(_adc_find_project "$project_override")" || return 1
  project_root="${project_file:h}"

  if [[ "$action" != watch ]]; then
    _adc_build_or_run \
      "$action" "$project_file" "$requested_scheme" "$selector" "$configuration" \
      "$bundle_id" "$derived_data" 0 "$requested_runtime"
    command_status=$?
    if (( command_status != 0 )); then
      _adc_terminal_status "❌ apple-device-control — $action failed" error
    fi
    return "$command_status"
  fi

  local previous_signature current_signature stable_signature
  local rebuild_status
  previous_signature="$(_adc_project_signature "$project_root")" || return 1
  _adc_build_or_run \
    run "$project_file" "$requested_scheme" "$selector" "$configuration" \
    "$bundle_id" "$derived_data" 1 "$requested_runtime"
  command_status=$?
  if (( command_status != 0 )); then
    _adc_terminal_status '❌ apple-device-control — Initial watch run failed' error
    return "$command_status"
  fi

  _adc_terminal_status "👀 apple-device-control — Watching ${project_root:t}" idle
  print -r -- "Watching $project_root (polling every ${interval}s; Ctrl-C to stop)."
  while true; do
    sleep "$interval"
    current_signature="$(_adc_project_signature "$project_root")" || return 1
    [[ "$current_signature" == "$previous_signature" ]] && continue

    print -r -- 'Project files changed; waiting for writes to settle...'
    _adc_terminal_status '⏳ apple-device-control — Waiting for writes to settle' busy
    stable_signature="$current_signature"
    while true; do
      sleep 1
      current_signature="$(_adc_project_signature "$project_root")" || return 1
      [[ "$current_signature" == "$stable_signature" ]] && break
      stable_signature="$current_signature"
    done

    print -r -- 'Change detected; rebuilding and reinstalling...'
    _adc_build_or_run \
      run "$project_file" "$requested_scheme" "$selector" "$configuration" \
      "$bundle_id" "$derived_data" 1 "$requested_runtime"
    rebuild_status=$?
    if (( rebuild_status != 0 )); then
      _adc_error 'build or deployment failed; still watching for the next change'
      _adc_terminal_status '⚠️ apple-device-control — Watching after build failure' idle
    else
      _adc_terminal_status "👀 apple-device-control — Watching ${project_root:t}" idle
    fi
    previous_signature="$stable_signature"
  done
}

_adc_main() {
  emulate -L zsh
  setopt pipefail

  local action="${1:-help}"
  (( $# > 0 )) && shift

  case "$action" in
    help|-h|--help) _adc_usage ;;
    devices) _adc_devices "$@" ;;
    build|run|watch) _adc_project_command "$action" "$@" ;;
    *) _adc_error "unknown command: $action"; _adc_usage >&2; return 2 ;;
  esac
}

# ~/.zshrc sources this file, making the command available in interactive shells.
apple-device-control() {
  _adc_main "$@"
}

