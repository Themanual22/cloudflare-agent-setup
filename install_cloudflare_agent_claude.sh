#!/usr/bin/env bash
# install_cloudflare_agent_claude.sh
set -euo pipefail

echo "== Cloudflare Agent setup for Claude =="
if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: 'claude' is not installed or not in PATH."
  echo "Install the Claude CLI and re-run this script."
  exit 1
fi

claude plugin marketplace add cloudflare/skills
claude plugin install cloudflare@cloudflare

echo "Done. In Claude, run: /reload-plugins"
