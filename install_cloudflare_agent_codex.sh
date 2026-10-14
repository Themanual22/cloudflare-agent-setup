#!/usr/bin/env bash
# install_cloudflare_agent_codex.sh
set -euo pipefail

echo "== Cloudflare Agent setup for OpenAI Codex =="
if ! command -v codex >/dev/null 2>&1; then
  echo "ERROR: 'codex' is not installed or not in PATH."
  echo "Install the Codex CLI and re-run this script."
  exit 1
fi

codex mcp add cloudflare --url https://mcp.cloudflare.com/mcp || true
codex mcp add cloudflare-docs --url https://docs.mcp.cloudflare.com/mcp || true
codex mcp add cloudflare-bindings --url https://bindings.mcp.cloudflare.com/mcp || true
codex mcp add cloudflare-builds --url https://builds.mcp.cloudflare.com/mcp || true
codex mcp add cloudflare-observability --url https://observability.mcp.cloudflare.com/mcp || true
codex mcp login cloudflare || true

echo "Codex MCP registration attempted. If login is interactive, complete the browser process."
