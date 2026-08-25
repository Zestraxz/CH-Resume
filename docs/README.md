# Resume — Documentation

> Numbered subfolders sort themselves. Read in order, or jump to what you need.

---

## Folder map

| # | Folder | Contains |
|---|---|---|
| `00` | [00-start-here/](00-start-here/) | Onboarding, install, quickstart, first 30 minutes |
| `01` | [01-session/](01-session/) | Session metadata (Claude Code paths, terminal context) |
| `02` | [02-governance/](02-governance/) | Contributing, governance, taxonomy, security, privacy |
| `03` | [03-deployment/](03-deployment/) | Runbook, deployment, infra, on-call |
| `04` | [04-quality/](04-quality/) | ADRs, review templates, review ledger |
| `05` | [05-workflows/](05-workflows/) | Repeatable prompt routines and playbooks |
| `99` | [99-archive/](99-archive/) | Frozen historical docs |

## Reserved number ranges

| Range | Use |
|---|---|
| 00–09 | Onboarding & session |
| 10–19 | Reserved (e.g., user-facing tutorials) |
| 20–29 | Governance variants |
| 30–39 | Deployment variants |
| 40–49 | Quality variants |
| 50–59 | Workflow variants |
| 60–98 | Reserved |
| 99 | Archive (always last) |

## Adding a new doc

1. Pick the right folder (or create a numbered sibling if the topic doesn't fit).
2. Use `kebab-case-name.md` (lowercase).
3. Add a one-line entry to the parent folder's README (if one exists).
4. Cross-link from any related doc.

## When a doc goes stale

Don't delete it — move it to [99-archive/](99-archive/) with a note explaining why.
