ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export PATH="${PATH}:${HOME}/.local/bin"

# Brew must be on PATH before Oh My Zsh and other tools resolve commands.
source "$ZSH_CONFIG_DIR/brew.zsh"

# -----------------------------------------------------------------------------
# Tmux
# -----------------------------------------------------------------------------

if [[ -o interactive && -z ${TMUX-} && -n "${GHOSTTY_RESOURCES_DIR:-}" ]] && command -v tmux >/dev/null 2>&1; then
  _tmux_bin="${commands[tmux]}"
  if [[ -n ${commands[ghostty]-} ]]; then
    _ghostty_bin="${commands[ghostty]}"
  elif [[ $OSTYPE == darwin* && -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]]; then
    _ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty
  else
    _ghostty_bin=
  fi

  typeset -a tmux_sessions

  tmux_sessions=(${(@f)$(tmux list-sessions -F $'#{session_name}' 2>/dev/null)}) || tmux_sessions=()
  ghostty_instance_running=false
 
  for row in "${(@f)$(tmux list-clients -F $'#{client_session}\t#{client_termname}' 2>/dev/null)}"; do
    values=("${(@ps:\t:)row}")
    session=$values[1]
    termname=$values[2]

    if [[ $termname == "xterm-ghostty" ]]; then
      ghostty_instance_running=true
    fi

    [[ -n $session ]] || continue
    tmux_sessions=(${tmux_sessions:#($session)})
  done

  if (( ${#tmux_sessions} == 0 )); then
    # if no tmux sessions need to be attached, create a new session.
    exec "$_tmux_bin" new-session
  elif $ghostty_instance_running; then
    # not all sessions are attached, but there is a ghostty instance running, create a new session (might've clicked on "New Window")
    exec "$_tmux_bin" new-session
  else
    # not all sessions are attached, and ghostty_instance is not running. load the first session on this terminal, and any other
    # sessions missing launch them in new window (or tab?)

    exec "$_tmux_bin" attach-session -t "$tmux_sessions[1]"

    for session in "${tmux_sessions[@]:1}"; do
      if [[ $OSTYPE == darwin* ]]; then
        # TODO: use applescript
        open -na Ghostty.app --args -e "$_tmux_bin" attach-session -t "$session"
      elif [[ -n $_ghostty_bin ]]; then
        "$_ghostty_bin" +new-window -e "$_tmux_bin" attach-session -t "$session"
      fi
    done
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
