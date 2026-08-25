# .claude/ — Claude Code Project Config

> Project-level Claude Code settings. Layered on top of `~/.claude/settings.json`.

---

## Files

| File | Purpose |
|---|---|
| `settings.json` | Permissions, env vars, hooks paths |
| `README.md` | This file |

## Permissions

`settings.json` defines two lists:

- **allow** — tools that auto-execute without asking
- **deny** — tools that are blocked entirely

Common rules pre-allowed:
- `pnpm`, `npm`, `node`, `python`, `pip`
- `docker`, `docker compose`
- Read-only git (`status`, `diff`, `log`, `branch`, `show`)
- Read-only GitHub CLI (`gh pr list`, `gh pr view`, etc.)

Common rules pre-denied:
- `git push --force` (always confirm)
- `git reset --hard` (always confirm)
- `rm -rf`, `sudo` (require explicit ask)

## Adding permissions

Run `/fewer-permission-prompts` to scan your session for common prompts and auto-add safe allows.

Or manually edit `settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(your-tool:*)"
    ]
  }
}
```

## Layered config

| Layer | Path | Notes |
|---|---|---|
| User global | `~/.claude/settings.json` | Applies to all projects |
| Project | `.claude/settings.json` | This file; overrides user global |
| Project-local | `.claude/settings.local.json` | gitignored; personal overrides |

## Auto-discovered folders

Claude Code auto-loads from these project folders (relative to repo root):

| Folder | Loaded? | How |
|---|---|---|
| `agents/` | ✅ | Each `<name>.md` is invocable |
| `skills/` | ✅ | Each `<name>/SKILL.md` is invocable |
| `commands/` | ✅ | Each `<name>.md` becomes `/<name>` |
| `hooks/` | ✅ | `hooks.json` registers handlers |
| `mcp-configs/` | ❌ (manual) | Templates only; splice into `~/.claude.json` |
| `rules/` | ❌ (manual) | Reference from CLAUDE.md or skills |

## See also

- [../CLAUDE.md](../CLAUDE.md) — project AI workflow conventions
- [../AGENTS.md](../AGENTS.md) — Codex CLI mirror
- [../.github/copilot-instructions.md](../.github/copilot-instructions.md) — Copilot pointer
