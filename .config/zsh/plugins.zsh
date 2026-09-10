check_and_install_plugins() {
  emulate -L zsh
  local custom_dir="${ZSH_CUSTOM:-$ZSH/custom}"
  local entry name repo installed_any=0

  for entry in "${external_plugins[@]}"; do
    name="${entry%%:*}"
    repo="${entry#*:}"

    [[ -d "$ZSH/plugins/$name" || -d "$custom_dir/plugins/$name" ]] && continue

    print -P "%F{cyan}Installing $name...%f"
    if git clone --depth=1 "$repo" "$custom_dir/plugins/$name"; then
      installed_any=1
    else
      print -P "%F{red}Failed to install $name.%f"
    fi
  done

  (( installed_any )) && print -P "%F{green}Done. Missing plugins installed.%f"
}
