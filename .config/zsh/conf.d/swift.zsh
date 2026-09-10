if [[ "$OSTYPE" == darwin* ]]; then
  [[ -r "$HOME/.swiftly/env.sh" ]] && source "$HOME/.swiftly/env.sh"
else
  [[ -r "$HOME/.local/share/swiftly/env.sh" ]] && source "$HOME/.local/share/swiftly/env.sh"
fi
