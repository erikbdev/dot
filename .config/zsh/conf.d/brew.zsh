_brew_bin="$(command -v brew 2>/dev/null)"
if [[ ! -x "$_brew_bin" ]]; then
  for _brew_candidate in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
  do
    if [[ -x "$_brew_candidate" ]]; then
      _brew_bin="$_brew_candidate"
      break
    fi
  done
fi

if [[ -x "$_brew_bin" ]]; then
  eval "$("$_brew_bin" shellenv)"
fi

unset _brew_bin _brew_candidate
