dot() {
  command git -C "$HOME" \
    --git-dir="$HOME/.dotfiles" \
    --work-tree="$HOME" \
    "$@"
}
