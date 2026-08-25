# Resume

> TODO: one-line description of Resume — TODO: target user.

[![CI](https://img.shields.io/badge/CI-pending-lightgrey)](#)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/Zestraxz/resume/badge)](https://scorecard.dev/viewer/?uri=github.com/Zestraxz/resume)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Status](https://img.shields.io/badge/status-Phase%201-orange)](STATUS.md)

> Target OpenSSF Scorecard >= 8/10. Improvements live in [docs/02-governance/SECURITY.md](docs/02-governance/SECURITY.md).

---

## What it does

TODO: paragraph describing Resume

## Project intelligence — where everything lives

> Stable pointers only - no numbers, no status words (those rot; they live in the files below).
> Same heading and shape in every CH repo, so one glance works anywhere.

| What you want | Where | Kept fresh by |
|---|---|---|
| Current state & phase | [STATUS.md](STATUS.md) | every meaningful commit |
| Living record - decisions / results / evidence | [PROJECT_ARTIFACT.md](PROJECT_ARTIFACT.md) | artifact duty (AGENTS.md §13), every meaningful event |
| Session transcripts (redacted) | `docs/01-session/transcripts/` | session-end backup (`scripts/04-sync/backup-session.ps1`) |
| Quality audits & coverage | `docs/04-quality/critic/` | weekly Radar + `/critic` |
| Portfolio brain (read first) | the Brain repo - `MEMORY/CURRENT_PRIORITIES.md`, `MEMORY/PROJECT_INDEX.md` | learning loop (AGENTS.md Sec 1b) |
| This project's knowledge pack | Brain `PROJECTS/Resume/PROJECT.md` | session end, every meaningful event |
| Session ledger (Reasoning Trail) | `docs/01-session/` | session end (AGENTS.md Sec 13) |
| Binding conventions | [AGENTS.md](AGENTS.md) | canonical |

## Quick start

### Windows (one-click)

```cmd
.\START_HERE.cmd            REM bootstrap + start everything (no choices)
.\OPEN_ARTIFACTS.cmd        REM open README + docs + URLs
.\tools-gui\Setup-Env.cmd   REM GUI wizard to fill .env from .env.example (first run)
```

### Cross-platform

```bash
# PowerShell
.\01_setup\run.ps1

# Bash
./01_setup/run.sh
```

Opens at:
- App: http://localhost:3000
- API: http://localhost:8000 (if applicable)
- API docs: http://localhost:8000/docs

## One-click GUI launchers (`tools-gui/`)

For tasks where you make choices (commit messages, ADR titles, env values), double-click the matching `.cmd` to open a small WinForms wizard:

| Launcher | What it does |
|---|---|
| `tools-gui/Setup-Env.cmd` | Fill `.env` from `.env.example` via a form. Auto-generates secrets |
| `tools-gui/GitPush.cmd` | Compose Conventional Commits message + pick files + run pre-commit gate + push |
| `tools-gui/New-ADR.cmd` | New auto-numbered ADR from template |
| `tools-gui/New-RFC.cmd` (standard+) | New auto-numbered RFC from template |
| `tools-gui/Upgrade-Profile.cmd` (standard+) | Compare current to higher profile; generate diff report |

See `tools-gui/README.md` for the pattern + how to add your own.

## Project layout

```
Resume/
├── 01_setup/         # Bootstrap scripts (run me first)
├── 02_active/        # Current phase notes, architecture, roadmap
├── 03_history/       # Read-only versioned snapshots
├── 04_tools/         # Production-validated automation
├── 05_archive/       # Locked legacy (do not touch)
│
├── apps/             # Runnable applications (if monorepo)
├── packages/         # Shared libraries (if monorepo)
├── src/              # Single-app source (if not monorepo)
├── tests/            # Test suite (unit, integration, e2e)
│
├── docs/             # Numbered documentation tree (00-99)
├── scripts/          # Lifecycle scripts by phase (00-04)
│
├── .claude/          # Claude Code config
├── agents/           # Custom subagents
├── skills/           # Skills
├── commands/         # Slash commands
├── hooks/            # Hooks
├── mcp-configs/      # MCP server templates
├── rules/            # Layered AI rules (common/ + overrides)
│
├── CLAUDE.md         # AI assistant governance (single source of truth)
├── AGENTS.md         # Codex CLI mirror
├── STATUS.md         # Current phase tracking
└── PROJECT_STRUCTURE.md
```

Full tree explanation: [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md).

## Documentation

| Where | What |
|---|---|
| [AGENTS.md](AGENTS.md) | Canonical AI-assistant brief (per [agents.md spec](https://agents.md/)) |
| [STATUS.md](STATUS.md) | Where the project stands right now |
| [docs/00-start-here/](docs/00-start-here/) | Onboarding & install |
| [docs/02-governance/](docs/02-governance/) | Contributing, governance, security |
| [docs/03-deployment/](docs/03-deployment/) | Runbook & deployment |
| [docs/04-quality/adr/](docs/04-quality/adr/) | Architecture Decision Records |
| [docs/05-workflows/](docs/05-workflows/) | Repeatable prompt routines |
| [evals/](evals/) | LLM evaluations (if app uses LLMs at runtime) |

## Stack

- **Backend:** TODO
- **Frontend:** TODO
- **Data:** PostgreSQL + Redis
- **Infra:** Docker Compose (dev) → TODO: cloud / k8s / VPS
- **AI:** Claude Code + Codex CLI + GitHub Copilot

## Pre-production checklist

- [ ] All secrets in `.env` (never committed); `.env.example` reflects every variable
- [ ] `CORS_ORIGINS`, `JWT_SECRET`, `DATABASE_URL` set for production
- [ ] HTTPS enforced at the edge
- [ ] Database migrations versioned and tested
- [ ] Healthchecks return 200 for all services
- [ ] Logs flow to centralized aggregator
- [ ] Backup + restore tested

See [docs/03-deployment/RUNBOOK.md](docs/03-deployment/RUNBOOK.md) for full procedures.

## Contributing

See [docs/02-governance/CONTRIBUTING.md](docs/02-governance/CONTRIBUTING.md).
Code style and AI workflows: [CLAUDE.md](CLAUDE.md).

## License

MIT — see [LICENSE](LICENSE).
