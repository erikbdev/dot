ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export PATH="${PATH}:${HOME}/.local/bin"

# Brew must be on PATH before Oh My Zsh and other tools resolve commands.
source "$ZSH_CONFIG_DIR/brew.zsh"

# -----------------------------------------------------------------------------
# Session management
# -----------------------------------------------------------------------------

if [[ -o interactive && -z ${ZMX_SESSION:-} && -z ${GHOSTTY_ZMX_RESTORE:-} && -n "${GHOSTTY_RESOURCES_DIR:-}" ]] && command -v zmx >/dev/null 2>&1; then
  _zmx_bin="${commands[zmx]}"
  if [[ -n ${commands[ghostty]-} ]]; then
    _ghostty_bin="${commands[ghostty]}"
  elif [[ $OSTYPE == darwin* && -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]]; then
    _ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty
  else
    _ghostty_bin=
  fi

  typeset -a zmx_sessions

  zmx_sessions=()

  for row in "${(@f)$("$_zmx_bin" ls 2>/dev/null)}"; do
    values=("${(@ps:\t:)row}")
    session=${values[1]#*name=}
    clients=${values[3]#*clients=}
    [[ -n $session ]] || continue
    (( ${clients:-0} == 0 )) && zmx_sessions+=("$session")
  done

  if (( ${#zmx_sessions} == 0 )); then
    # if no zmx sessions need to be attached, create a new session.
    exec "$_zmx_bin" attach "session-$RANDOM"
  else
    # not all sessions are attached. load in new window (group into tabs/splits in the future? how to know split vs tab?)
    for session in "${zmx_sessions[@]:1}"; do
      if [[ $OSTYPE == darwin* ]]; then
        _zmx_command="exec ${(q)_zmx_bin} attach ${(q)session}"
        osascript \
          -e 'on run argv' \
          -e 'tell application "Ghostty"' \
          -e 'set cfg to new surface configuration' \
          -e 'set initial input of cfg to (item 1 of argv) & linefeed' \
          -e 'set wait after command of cfg to false' \
          -e 'set environment variables of cfg to {"GHOSTTY_ZMX_RESTORE=1", "ZDOTDIR=/nonexistent"}' \
          -e 'set win to new window with configuration cfg' \
          -e 'end tell' \
          -e 'end run' \
          "$_zmx_command" >/dev/null 2>&1 &!
      elif [[ -n $_ghostty_bin ]]; then
        "$_ghostty_bin" +new-window -e "$_zmx_bin" attach "$session" >/dev/null 2>&1 &!
      fi
    done

    exec "$_zmx_bin" attach "${zmx_sessions[1]}"
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
