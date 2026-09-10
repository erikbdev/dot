# -----------------------------------------------------------------------------
# TMUX 
# -----------------------------------------------------------------------------

ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [[ -r "$ZSH_CONFIG_DIR/conf.d/brew.zsh" ]]; then
  source "$ZSH_CONFIG_DIR/conf.d/brew.zsh"
fi

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
plugins=(git zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

# Load portable configuration converted from ~/.config/fish.
for zsh_config_file in "$ZSH_CONFIG_DIR"/conf.d/*.zsh(N); do
  [[ "$zsh_config_file" == "$ZSH_CONFIG_DIR/conf.d/brew.zsh" ]] && continue
  source "$zsh_config_file"
done
for zsh_function_file in "$ZSH_CONFIG_DIR"/functions/*.zsh(N); do
  source "$zsh_function_file"
done
unset zsh_config_file zsh_function_file

# -----------------------------------------------------------------------------
# Zsh completion
# -----------------------------------------------------------------------------

# Interactive completion menu and forgiving matching.
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

# Search only history entries matching what is already typed.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# -----------------------------------------------------------------------------
# Fish-like navigation and fuzzy search
# -----------------------------------------------------------------------------

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
