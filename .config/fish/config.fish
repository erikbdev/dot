/opt/homebrew/bin/brew shellenv | source

if status is-interactive
 set -x FONT "CommitMonoErikb Nerd Font Mono"
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

if status is-interactive
    atuin init fish | source
end
