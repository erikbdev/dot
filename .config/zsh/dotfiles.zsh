dot() {
  command git -C "$HOME" \
    --git-dir="$HOME/.dotfiles" \
    --work-tree="$HOME" \
    "$@"
}

# Complete only tracked files with staged or unstaged changes for `dot add`.
_dotfiles_changed_paths() {
  local -a changed_paths

  changed_paths=(${(f)"$(
    dot diff --name-only --diff-filter=ACDMRTUXB
    dot diff --cached --name-only --diff-filter=ACDMRTUXB
  )"})
  changed_paths=(${(u)changed_paths})

  if (( ${#changed_paths} == 0 )); then
    _message 'no tracked changes'
    return 0
  fi

  _describe 'changed tracked files' changed_paths
}

_dotfiles_completion() {
  if [[ ${words[2]-} == add && $CURRENT -ge 3 ]]; then
    _dotfiles_changed_paths
    return
  fi

  if (( $+functions[_git] )); then
    _git
  else
    _message 'dot add <changed-tracked-file>'
  fi
}

compdef _dotfiles_completion dot
