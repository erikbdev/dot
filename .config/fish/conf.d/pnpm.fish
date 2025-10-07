set -x PNPM_HOME "$HOME/.local/share/pnpm"

# Add PNPM_HOME to PATH if not already included
if not contains $PNPM_HOME $PATH
    set -x PATH $PNPM_HOME $PATH
end
