#!/usr/bin/env bash
# install_cloudflare_agent_for_copilot.sh
# Best-effort Cloudflare setup with Copilot priority and fallbacks.
set -euo pipefail

echo "== Cloudflare Agent setup helper (Copilot-first, with fallbacks) =="

run_try() {
  echo "+ $*"
  if ! "$@"; then
    echo "WARN: non-fatal failure: $*"
    return 1
  fi
  return 0
}

install_via_npx() {
  if command -v npx >/dev/null 2>&1; then
    echo "Installing Cloudflare skills via npx (global)..."
    run_try npx -y skills add cloudflare/skills --skill '*' --yes --global || true
  else
    echo "npx not found. Node.js/npm is not installed in this environment."
  fi
}

register_mcp_for_codex() {
  if command -v codex >/dev/null 2>&1; then
    echo "Registering Cloudflare MCP servers with codex..."
    run_try codex mcp add cloudflare --url https://mcp.cloudflare.com/mcp || true
    run_try codex mcp add cloudflare-docs --url https://docs.mcp.cloudflare.com/mcp || true
    run_try codex mcp add cloudflare-bindings --url https://bindings.mcp.cloudflare.com/mcp || true
    run_try codex mcp add cloudflare-builds --url https://builds.mcp.cloudflare.com/mcp || true
    run_try codex mcp add cloudflare-observability --url https://observability.mcp.cloudflare.com/mcp || true
    echo "Attempting cloudflare login with codex..."
    run_try codex mcp login cloudflare || true
  fi
}

configure_opencode() {
  local CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
  local CONFIG_FILE="$CONFIG_DIR/opencode.jsonc"
  mkdir -p "$CONFIG_DIR"

  if [ ! -f "$CONFIG_FILE" ] || [ ! -s "$CONFIG_FILE" ]; then
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
    echo "Created $CONFIG_FILE with Cloudflare MCP config."
    return 0
  fi

  if grep -q '"cloudflare"' "$CONFIG_FILE"; then
    echo "Cloudflare entry already present in $CONFIG_FILE."
    return 0
  fi

  echo "Existing $CONFIG_FILE does not contain a Cloudflare entry."
  cat <<'SNIPPET'

Add this block under the existing "mcp" object in $CONFIG_FILE:
"cloudflare": {
  "type": "remote",
  "url": "https://mcp.cloudflare.com/mcp",
  "enabled": true,
  "oauth": {}
},
SNIPPET
}

attempt_copilot() {
  if command -v copilot >/dev/null 2>&1; then
    echo "Detected 'copilot' CLI in PATH."
    if copilot --help 2>&1 | grep -qi plugin; then
      echo "Trying plugin marketplace and install commands for Copilot..."
      run_try copilot plugin marketplace add cloudflare/skills || true
      run_try copilot plugin install cloudflare@cloudflare || true
      echo "If your Copilot environment requires plugin reload, restart the agent after install."
      return 0
    fi
    echo "The installed copilot CLI does not appear to expose plugin commands."
  fi
  return 1
}

attempt_claude() {
  if command -v claude >/dev/null 2>&1; then
    echo "Detected 'claude' CLI in PATH."
    run_try claude plugin marketplace add cloudflare/skills || true
    run_try claude plugin install cloudflare@cloudflare || true
    echo "In Claude, run /reload-plugins after installation."
    return 0
  fi
  return 1
}

if attempt_copilot; then
  echo "Copilot setup attempted."
else
  echo "No Copilot plugin mode detected. Falling back to other setup paths."
fi

if attempt_claude; then
  echo "Claude setup attempted."
fi

install_via_npx
register_mcp_for_codex
configure_opencode

echo ""
echo "Cloudflare setup script finished."
echo "If interactive login is needed, complete the browser-based OAuth prompts."
echo "For manual registration, use the following MCP endpoints:"
echo "  https://mcp.cloudflare.com/mcp"
echo "  https://docs.mcp.cloudflare.com/mcp"
echo "  https://bindings.mcp.cloudflare.com/mcp"
echo "  https://builds.mcp.cloudflare.com/mcp"
echo "  https://observability.mcp.cloudflare.com/mcp"
echo ""
echo "Useful next steps:"
echo "  - Claude: claude plugin marketplace add cloudflare/skills && claude plugin install cloudflare@cloudflare && /reload-plugins"
echo "  - Codex: codex mcp add cloudflare --url https://mcp.cloudflare.com/mcp && codex mcp login cloudflare"
echo "  - OpenCode: add the cloudflare MCP entry under mcp in ~/.config/opencode/opencode.jsonc"
