# Taxonomy — Resume

> Controlled vocabulary used across the project. Use these terms; don't invent synonyms.

---

## Asset categories

| Category | Marker | Lives in | Purpose |
|---|---|---|---|
| **Skill** | `SKILL.md` (frontmatter) | `skills/<name>/` | Claude-invocable knowledge module |
| **Agent** | `<name>.md` (frontmatter) | `agents/` | Subagent with system prompt |
| **Command** | `<name>.md` (frontmatter) | `commands/` | Slash command |
| **Hook** | entry in `hooks.json` | `hooks/` | Event handler (PostToolUse, etc.) |
| **MCP server** | entry in `mcp-servers.json` | `mcp-configs/` | Tool provider |
| **Rule** | markdown file | `rules/common/` + `rules/<domain>/` | AI coding standard |

## Naming

- **Asset names:** `kebab-case`, 3–48 chars, must start with a letter. Examples: `ch-prompt-routine`, `web-coding-style`.
- **File names (code):** `camelCase.ts`, `PascalCase.tsx` (React), `snake_case.py`.
- **Folder names:** `kebab-case` for assets, `snake_case` for Python packages, lowercase for everything else.
- **Branch names:** `<type>/<short-desc>` (`feat/add-cases-endpoint`).

## Tagging vocabulary (for asset frontmatter)

### Domain tags
`api`, `web`, `data`, `infra`, `ai`, `docs`, `testing`, `security`, `ops`

### Capability tags
`bootstrap`, `validate`, `generate`, `analyze`, `transform`, `deploy`, `monitor`

### Sensitivity tags
`safe` (no destructive ops), `caution` (modifies state), `destructive` (deletes/overwrites), `requires-approval`

Example frontmatter:
```yaml
---
name: db-reset
description: Drop and recreate the dev database from migrations
domain: data
capabilities: [bootstrap, transform]
sensitivity: destructive
---
```

## Status terms

| Term | Meaning |
|---|---|
| `pending` | Not started |
| `in_progress` | Being worked on |
| `blocked` | Waiting on external dependency |
| `completed` | Done, merged, validated |
| `deferred` | Decided not to pursue now |
| `superseded` | Replaced by a later decision (link to successor) |

## Severity (for issues / incidents)

| Level | Definition | Response time |
|---|---|---|
| **P0** | Production down / data loss | < 1 hour |
| **P1** | Major feature broken / no workaround | < 4 hours |
| **P2** | Bug with workaround | < 2 business days |
| **P3** | Cosmetic / minor | Next sprint |

## Phase numbers

See [../../STATUS.md](../../STATUS.md). Phases are numbered 1–5 by convention; reset when project enters a new major version.
