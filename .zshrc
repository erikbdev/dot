ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export PATH="${PATH}:${HOME}/.local/bin"

# Brew must be on PATH before Oh My Zsh and other tools resolve commands.
source "$ZSH_CONFIG_DIR/brew.zsh"

# -----------------------------------------------------------------------------
# Tmux
# -----------------------------------------------------------------------------

if [[ -o interactive && -z ${TMUX-} && ( "${TERM_PROGRAM:-}" == ghostty || -n "${GHOSTTY_RESOURCES_DIR:-}" ) ]]; then
  if command -v tmux >/dev/null 2>&1; then
    exec tmux new-session -A -s main
  elif [[ -x /opt/homebrew/bin/tmux ]]; then
    exec /opt/homebrew/bin/tmux new-session -A -s main
  elif [[ -x /usr/local/bin/tmux ]]; then
    exec /usr/local/bin/tmux new-session -A -s main
  fi
fi

# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

omz_plugins=(git)
external_plugins=(
  "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search.git"
  "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
)

# Install any missing external plugins before Oh My Zsh loads them.
source "$ZSH_CONFIG_DIR/plugins.zsh"
check_and_install_plugins

plugins=($omz_plugins "${(@)external_plugins%%:*}")
source "$ZSH/oh-my-zsh.sh"

# -----------------------------------------------------------------------------
# Config modules
# -----------------------------------------------------------------------------

for _zsh_file in "$ZSH_CONFIG_DIR"/*.zsh(N); do
  case "$_zsh_file" in
    */brew.zsh|*/plugins.zsh) continue ;;
  esac
  source "$_zsh_file"
done
unset _zsh_file

# -----------------------------------------------------------------------------
# Completion
# -----------------------------------------------------------------------------

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

setopt COMPLETE_IN_WORD
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS

# Search history entries matching the typed prefix.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# -----------------------------------------------------------------------------
# Tools
# -----------------------------------------------------------------------------

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
