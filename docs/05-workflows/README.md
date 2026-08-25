# 05 Workflows

> Repeatable prompt routines and procedural playbooks. The "how we do X" library.

---

## What goes here

- **Prompt routines** — multi-step Claude / Codex prompts that produce a specific artifact (`slash command` style but documented)
- **Procedural playbooks** — non-AI procedures that recur (release, hotfix, dependency upgrade)
- **Migration guides** — when you change a convention, how existing code migrates

## What does NOT go here

- One-off task notes (use `02_active/` or just commit messages)
- Operational procedures (use `03-deployment/RUNBOOK.md`)
- AI configuration (use `../../rules/`, `../../skills/`, `../../agents/`)

## Index

| Workflow | File | When to use |
|---|---|---|
| _(add as you create them)_ | | |

## Template for new workflow

```markdown
# Workflow — <Name>

**Purpose:** What this accomplishes in one sentence.
**Trigger:** When you'd run this (event / cadence / felt need).
**Owner:** Who owns updates.
**Last run:** YYYY-MM-DD.

## Inputs
- ...

## Steps
1. ...
2. ...

## Outputs
- ...

## Common gotchas
- ...
```
