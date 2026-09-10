dev() {
  emulate -L zsh

  local dockerfile=Dockerfile
  local dockerpath=podman
  local docker_bin
  local current_dir
  local dir_name
  local dir_hash
  local image
  local container
  local debug=0

  while (( $# > 0 )); do
    case "$1" in
      --dockerfile)
        if (( $# < 2 )); then
          print -u2 -r -- "dev: --dockerfile requires a value"
          return 2
        fi
        dockerfile="$2"
        shift 2
        ;;
      --dockerfile=*)
        dockerfile="${1#*=}"
        shift
        ;;
      --dockerpath)
        if (( $# < 2 )); then
          print -u2 -r -- "dev: --dockerpath requires a value"
          return 2
        fi
        dockerpath="$2"
        shift 2
        ;;
      --dockerpath=*)
        dockerpath="${1#*=}"
        shift
        ;;
      -d|--debug)
        debug=1
        shift
        ;;
      -h|--help)
        print -r -- 'Usage: dev [options]

OPTIONS:
    --dockerfile    The Dockerfile to use (default: Dockerfile)
    --dockerpath    The path or command for Docker/Podman (default: podman)
    -d, --debug     Print resolved project and container details
    -h, --help      Show this help
'
        return 0
        ;;
      --)
        shift
        break
        ;;
      *)
        print -u2 -r -- "dev: unknown option: $1"
        return 2
        ;;
    esac
  done

  if (( $# > 0 )); then
    print -u2 -r -- "dev: unexpected argument: $1"
    return 2
  fi

  if [[ "$dockerpath" == */* ]]; then
    docker_bin="$dockerpath"
  else
    docker_bin="$(command -v "$dockerpath" 2>/dev/null)"
  fi

  if [[ ! -x "$docker_bin" ]]; then
    print -u2 -r -- "Error: Docker/Podman command '$dockerpath' not found."
    return 1
  fi

  current_dir="$PWD"
  dir_name="${current_dir##*/}"
  [[ -n "$dir_name" ]] || dir_name=root
  dir_name="${dir_name//[^A-Za-z0-9_.-]/-}"

  if command -v sha256sum >/dev/null 2>&1; then
    dir_hash="$(printf '%s' "$current_dir" | sha256sum | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    dir_hash="$(printf '%s' "$current_dir" | shasum -a 256 | awk '{print $1}')"
  else
    print -u2 -r -- 'Error: neither sha256sum nor shasum is available.'
    return 1
  fi

  image="${dir_name}-${dir_hash}"
  container="$image"

  if (( debug )); then
    print -r -- "current_dir '$current_dir', dir_name '$dir_name', dir_hash '$dir_hash', image '$image', container '$container', dockerfile '$dockerfile', dockerpath '$dockerpath'"
  fi

  if [[ ! -e "$dockerfile" ]]; then
    print -u2 -r -- "Error: Dockerfile '$dockerfile' not found."
    return 1
  fi

  print -r -- "Building image: $image"
  "$docker_bin" build -t "$image" -f "$dockerfile" "$current_dir" || return 1

  print -r -- "Creating and starting container $container"
  "$docker_bin" run -it \
    --name "$container" \
    --hostname "$dir_name" \
    -v "$current_dir:/workspace:Z" \
    --user 1000:1000 \
    -w /workspace \
    --replace \
    --entrypoint bash \
    "$image"
}
