export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"

if [[ ":${PATH:-}:" != *":${PNPM_HOME}:"* ]]; then
  export PATH="$PNPM_HOME:$PATH"
fi
