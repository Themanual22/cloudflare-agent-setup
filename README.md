# Cloudflare Agent Setup

This repository contains a best-effort setup for Cloudflare Agent integration in a browser/cloud workspace.

It prefers GitHub Copilot, with fallback support for Claude, OpenAI Codex, and OpenCode. The scripts are designed to run in a browser workspace (for example, Gitpod) and to print the exact manual steps when interactive authentication is required.

## What is included

- `install_cloudflare_agent_for_copilot.sh` — unified installer with Copilot-first behavior and fallbacks
- `install_cloudflare_agent_claude.sh` — Claude setup commands from the Cloudflare prompt
- `install_cloudflare_agent_codex.sh` — Codex MCP registry and login commands
- `install_cloudflare_agent_opencode.sh` — OpenCode config update for Cloudflare MCP
- `.gitpod.yml` — auto-runs the setup when the workspace is created

## Quick start in Gitpod

Open this repository in Gitpod. The workspace config will automatically run the unified installer.

If you prefer to run manually:

```bash
chmod +x ./install_cloudflare_agent_for_copilot.sh
./install_cloudflare_agent_for_copilot.sh
```

## Important notes

- The Cloudflare setup documentation includes remote MCP URLs and OAuth login flows.
- Browser or interactive auth may still be required after the scripts run.
- Some agents (for example, Copilot and Claude) may require a plugin or MCP configuration inside the agent UI, not just CLI commands.
- If you already have an agent installed, the script will try to detect it and configure the correct integration.

## Cloudflare MCP endpoints used

```text
https://mcp.cloudflare.com/mcp
https://docs.mcp.cloudflare.com/mcp
https://bindings.mcp.cloudflare.com/mcp
https://builds.mcp.cloudflare.com/mcp
https://observability.mcp.cloudflare.com/mcp
```

## Manual follow-up steps

### Claude

```bash
claude plugin marketplace add cloudflare/skills
claude plugin install cloudflare@cloudflare
```

Then inside Claude run:

```text
/reload-plugins
```

### Codex

```bash
codex mcp add cloudflare --url https://mcp.cloudflare.com/mcp
codex mcp add cloudflare-docs --url https://docs.mcp.cloudflare.com/mcp
codex mcp add cloudflare-bindings --url https://bindings.mcp.cloudflare.com/mcp
codex mcp add cloudflare-builds --url https://builds.mcp.cloudflare.com/mcp
codex mcp add cloudflare-observability --url https://observability.mcp.cloudflare.com/mcp
codex mcp login cloudflare
```

### OpenCode

Add the following under the existing `mcp` object in `~/.config/opencode/opencode.jsonc`:

```json
"cloudflare": {
  "type": "remote",
  "url": "https://mcp.cloudflare.com/mcp",
  "enabled": true,
  "oauth": {}
}
```

## License

MIT
