# skills/ — Claude Skills

> Each `<name>/SKILL.md` is an invocable knowledge module.

---

## Folder structure

```
skills/
├── my-skill/
│   ├── SKILL.md           # required: frontmatter + body
│   ├── scripts/           # optional: helper scripts
│   ├── examples/          # optional: example outputs
│   └── templates/         # optional: file templates
└── another-skill/
    └── SKILL.md
```

## SKILL.md format

```markdown
---
name: my-skill
description: |
  When to trigger this skill. Be specific — Claude reads this to decide whether
  to invoke. Include trigger phrases users typically say.
license: MIT
---

# My Skill

## Purpose

What this skill does in one paragraph.

## When to use

- "Trigger phrase 1"
- "Trigger phrase 2"
- Symptom or situation 1
- Symptom or situation 2

## How it works

Step-by-step instructions for the model to follow.

1. Read the user's request and extract X.
2. ...

## Templates / examples

Reference files in `templates/` or `examples/`.
```

## Naming

- `kebab-case` folder names
- 3–48 chars
- Filename inside is always `SKILL.md` (uppercase)

## Best practices

- **Specific descriptions:** the `description` field is what Claude reads to decide whether to invoke. Vague descriptions = wrong invocations.
- **Include negative examples:** "Do NOT use this for X" prevents mis-routing.
- **Self-contained:** the skill should work from cold context — don't assume the model remembers anything.
- **Test triggers:** put example user prompts in a `tests/trigger.md` file.

## See also

- [../agents/README.md](../agents/README.md) — subagents (with isolated context)
- Anthropic docs: https://docs.anthropic.com/en/docs/claude-code/skills
