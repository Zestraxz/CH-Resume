# commands/ — Slash Commands

> Each `<name>.md` becomes a `/<name>` slash command.

---

## Format

```markdown
---
description: One-line description shown in the / picker
allowed-tools:
  - Read
  - Glob
  - Grep
argument-hint: "<arg1> [arg2]"
---

# /my-command

Body of the prompt that runs when the user types `/my-command $ARGUMENTS`.

$ARGUMENTS is replaced with whatever the user typed after the command name.
```

## Naming

- `kebab-case.md`
- Filename = command name (`my-command.md` → `/my-command`)

## Example

```markdown
---
description: Summarize a PR by URL
allowed-tools:
  - Bash(gh:*)
  - Read
argument-hint: "<pr-url>"
---

# /pr-summary

Summarize the GitHub PR at $ARGUMENTS in 5 bullets:
- What changed
- Why it changed
- Tests added
- Risks
- Suggested follow-ups

Use `gh pr view $ARGUMENTS --json title,body,additions,deletions,files` to fetch.
```

## Best practices

- Keep the body focused — one task per command
- Use `$ARGUMENTS` for user input; don't ask follow-up questions
- Restrict `allowed-tools` to the minimum needed
- Provide `argument-hint` so users see expected input format

## See also

- Anthropic docs: https://docs.anthropic.com/en/docs/claude-code/slash-commands
