# mcp-configs/ — MCP Server Templates

> Templates for MCP servers. **Not auto-loaded.** Splice into `~/.claude.json` manually.

---

## Files

| File | Purpose |
|---|---|
| `mcp-servers.json` | Template with `YOUR_*_HERE` placeholders |
| `README.md` | This file |

## Why templates, not live config?

MCP servers often need secrets (GitHub tokens, DB connection strings, API keys). Committing live secrets is forbidden. Instead:

1. Edit `mcp-servers.json` to add the servers you want.
2. Replace placeholders with real values **in `~/.claude.json`**, not in this file.
3. Re-run `claude mcp list` to verify.

## Adding to `~/.claude.json`

```jsonc
{
  "mcpServers": {
    // ... existing servers ...
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
      // Official remote server: authenticate once via /mcp in an interactive
      // claude session (OAuth). No personal access token is stored anywhere.
    }
  }
}
```

Or use the CLI:

```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
```

## Common MCP servers (the Brain-blessed defaults, 2026-08)

| Server | Use for | Note |
|---|---|---|
| Remote GitHub (`https://api.githubcopilot.com/mcp/`) | GitHub issues, PRs, repos | Official, OAuth. **Do NOT use `@modelcontextprotocol/server-github` - deprecated, frozen at 2025.4.8** |
| `crystaldba/postgres-mcp:0.3.0` (docker, `--access-mode=restricted`) | Live DB queries | Read-only role + restricted mode. **Do NOT use `@modelcontextprotocol/server-postgres` - archived with an unpatched SQL injection** |
| `@modelcontextprotocol/server-filesystem@2026.7.10` | Access files outside repo | Pin the version; scope the allowed directory narrowly |
| `@modelcontextprotocol/server-slack` | Slack messaging | Credential-scoped - per-project, not global |
| `@modelcontextprotocol/server-puppeteer` | Browser automation | Heavy - enable per project only |

Scope rule (from the CH-MCP standard): a server's scope = the narrowest of where it is
useful x where its credentials should reach x what its context cost buys. Global only for
universal, credential-free/account-level, small servers. Keep fewer than ~10 enabled.
Before enabling any server: state the least-privilege credential, keep secrets out of
committed files, handshake-verify the exact launch command, record the decision in
PROJECT_ARTIFACT.md.

Full registry: https://github.com/modelcontextprotocol/servers

## Verifying

```bash
claude mcp list          # see registered servers
claude mcp logs github   # tail logs for a specific server
```

## Removing a server

```bash
claude mcp remove github
```
