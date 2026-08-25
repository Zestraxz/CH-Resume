# hooks/ — Claude Code Hooks

> Declarative event handlers. Loaded from `hooks.json`.

---

## Events

| Event | When it fires |
|---|---|
| `PreToolUse` | Before a tool runs (can block) |
| `PostToolUse` | After a tool runs |
| `Stop` | When the assistant turn ends |
| `SessionStart` | When Claude starts a session in this repo |
| `SessionEnd` | When the session terminates |
| `PreCompact` | Before context is compacted |

## Format (`hooks.json`)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "pnpm format --write {{file_paths}}",
            "timeout": 30
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell -File scripts/02-verify/verify-local.ps1"
          }
        ]
      }
    ]
  }
}
```

## Matcher syntax

- Regex matched against tool name (`Bash`, `Edit`, etc.)
- Use `|` for OR: `Edit|Write|MultiEdit`
- Use `.*` to match all tools

## Hook types

| Type | Behavior |
|---|---|
| `command` | Runs a shell command; non-zero exit can block (PreToolUse only) |
| `script` | Runs a script file |

## Best practices

- **Keep hooks fast** — they run on every matching event
- **PreToolUse hooks can block** — use sparingly; they slow every tool call
- **Use SessionStart** for "verify environment" or "load context" steps
- **Use PostToolUse(Edit|Write)** for auto-format
- **Test hooks** by triggering the event and reading logs

## See also

- Anthropic docs: https://docs.anthropic.com/en/docs/claude-code/hooks
