# Session Directory

> Where AI session artifacts live. Useful for resuming work and for AI assistants to find context.

---

## Local Claude paths

| Path | Purpose |
|---|---|
| `~/.claude/projects/<encoded-cwd>/` | Per-project session transcripts |
| `~/.claude/sessions/` | Global session history |
| `~/.claude/memory/MEMORY.md` | Persistent memory index |
| `~/.claude/settings.json` | Global Claude Code settings |

This project's encoded path:
```
~/.claude/projects/{{ENCODED_PROJECT_PATH}}/
```

## Project-local Claude paths

| Path | Purpose |
|---|---|
| `.claude/settings.json` | Project-level overrides |
| `.claude/README.md` | What's in `.claude/` and why |
| `agents/`, `skills/`, `commands/`, `hooks/`, `rules/`, `mcp-configs/` | Auto-discoverable extensions |

## Codex paths

| Path | Purpose |
|---|---|
| `~/.codex/` | Codex CLI home |
| `.codex/` | Project-local overrides (mirror of `.claude/`) |
| `AGENTS.md` | Codex's source of conventions (mirror of `CLAUDE.md`) |

## Copilot paths

| Path | Purpose |
|---|---|
| `.github/copilot-instructions.md` | Repo-level instructions for GitHub Copilot |

## Resuming a session

```bash
# Claude Code
claude --continue <session-id>

# Or by project
claude --resume          # picks most recent session for this cwd
```

## Cleaning up

Session data is local-only. To wipe:

```bash
# Per-project (this directory)
rm -rf ~/.claude/projects/{{ENCODED_PROJECT_PATH}}/

# Or use the user-level reset
# See: .CH-Claude-Reset/Reset-Claude.ps1
```
