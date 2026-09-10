check_and_install_plugins() {
  emulate -L zsh
  local custom_dir="${ZSH_CUSTOM:-$ZSH/custom}"
  local entry name repo installed_any=0

  for entry in "${all_plugins[@]}"; do
    name="${entry%%:*}"
    repo="${entry#*:}"

    # Already present (built-in or custom) — skip
    if [[ -d "$ZSH/plugins/$name" || -d "$custom_dir/plugins/$name" ]]; then
      continue
    fi

    if [[ -z "$repo" ]]; then
      print -P "%F{yellow}'$name' is missing and has no repo configured, skipping.%f"
      continue
    fi

    print -P "%F{cyan}Installing $name...%f"
    if git clone --depth=1 "$repo" "$custom_dir/plugins/$name"; then
      installed_any=1
    else
      print -P "%F{red}Failed to install $name.%f"
    fi
  done

  if (( installed_any )); then
    print -P "%F{green}Done. Missing plugins installed.%f"
  fi
}
