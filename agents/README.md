# agents/ — Custom Subagents

> Each `<name>.md` becomes an invocable subagent.

---

## Format

```markdown
---
name: example-agent
description: One-line description of when to use this agent
model: sonnet            # or: opus, haiku
color: cyan
tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# Example Agent — System Prompt

You are a specialized agent that ...

## Your role

...

## When you complete

Return a structured summary with:
- ...
```

## Naming

- `kebab-case.md`
- 3–48 chars
- Must start with a letter
- Filename = agent name = what shows in the agent picker

## Tool allow-list

Restrict tools the agent can use. Common patterns:

- **Research agent:** `Read`, `Glob`, `Grep`, `WebSearch`, `WebFetch`
- **Code reviewer:** `Read`, `Glob`, `Grep`, `Bash` (read-only)
- **Builder:** `Read`, `Write`, `Edit`, `Glob`, `Grep`, `Bash`
- **Investigator:** all tools

## Best practices

- One clear purpose per agent
- Pre-load context the agent will need (file paths, schemas, conventions)
- Set explicit "when you complete" instructions
- Constrain model size — `haiku` for fast lookups, `sonnet` for most work, `opus` for planning

## See also

- [../skills/README.md](../skills/README.md) — skills (knowledge modules)
- [../commands/README.md](../commands/README.md) — slash commands
- Anthropic docs: https://docs.anthropic.com/en/docs/claude-code/sub-agents
