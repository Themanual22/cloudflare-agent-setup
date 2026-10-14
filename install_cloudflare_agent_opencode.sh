#!/usr/bin/env bash
# install_cloudflare_agent_opencode.sh
set -euo pipefail

echo "== Cloudflare Agent setup for OpenCode =="
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.jsonc"
mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
  cp "$CONFIG_FILE" "${CONFIG_FILE}.bak.$(date +%s)"
fi

cat > "$CONFIG_FILE" <<'JSONC'
{
  "mcp": {
    "cloudflare": {
      "type": "remote",
      "url": "https://mcp.cloudflare.com/mcp",
      "enabled": true,
      "oauth": {}
    }
  }
}
JSONC

echo "OpenCode config written to $CONFIG_FILE"
echo "OAuth will trigger automatically the first time a Cloudflare tool is used."
