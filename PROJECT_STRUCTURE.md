# Resume — Project Structure

> Authoritative map of where everything lives and why.

---

## Top-level

```
Resume/
│
├── 01_setup/                  # Bootstrap scripts (run.ps1, run.sh, run.bat)
├── 02_active/                 # Current load-bearing reference (mutable)
├── 03_history/                # Read-only snapshots (recovery only)
├── 04_tools/                  # Production-validated ops automation
├── 05_archive/                # Locked legacy (do not touch)
│
├── apps/                      # Runnable applications (monorepo mode)
│   ├── api/                   # Backend service
│   └── web/                   # Frontend SPA
├── packages/                  # Shared libraries (monorepo mode)
│   └── shared/                # Domain truth: schemas, enums, state machine
├── src/                       # Single-app source (alternative to apps/)
├── tests/                     # Test suite (unit, integration, e2e)
│
├── docs/                      # Numbered documentation tree
│   ├── 00-start-here/         # Onboarding, install, quickstart
│   ├── 01-session/            # Session metadata, Claude paths
│   ├── 02-governance/         # Contributing, governance, security
│   ├── 03-deployment/         # Runbook, deployment, infra
│   ├── 04-quality/            # ADRs, reviews
│   ├── 05-workflows/          # Repeatable prompt routines
│   └── 99-archive/            # Frozen historical docs
│
├── scripts/                   # Lifecycle scripts by phase
│   ├── 00-start/              # Startup automation
│   ├── 01-setup/              # Environment setup
│   ├── 02-verify/             # Verification & smoke tests
│   ├── 03-database/           # Migrations, reset, seed
│   └── 04-sync/               # Config sync (project ↔ live)
│
├── tools-gui/                 # One-click GUI launchers (PRINCIPLES.md Sec 19)
│   ├── Setup-Env.cmd          # fill .env from .env.example (all profiles)
│   ├── GitPush.cmd            # Conventional Commits wizard (all profiles)
│   ├── New-ADR.cmd            # new ADR from template (all profiles)
│   ├── New-RFC.cmd            # new RFC from template (standard+)
│   └── Upgrade-Profile.cmd    # profile-diff report (standard+)
│
├── .claude/                   # Claude Code project config
├── agents/                    # Custom subagents
├── skills/                    # Skills (each in own folder)
├── commands/                  # Slash commands
├── hooks/                     # Hooks (hooks.json + handlers)
├── mcp-configs/               # MCP server templates
├── rules/                     # Layered AI rules (common/ + overrides)
│
├── .github/                   # CI/CD, issue templates, copilot config
│   ├── workflows/
│   ├── ISSUE_TEMPLATE/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── dependabot.yml
│   └── copilot-instructions.md
│
├── public/                    # Frontend static assets (single-app)
├── assets-source/             # Pre-build source assets (archival)
│
├── CLAUDE.md                  # AI governance (single source of truth)
├── AGENTS.md                  # Codex CLI mirror
├── STATUS.md                  # Current phase tracking
├── CHANGELOG.md               # Keep a Changelog
├── CODEOWNERS                 # Per-folder ownership
├── README.md                  # Project overview
├── START_HERE.md              # Cold-reader onboarding
├── START_HERE.cmd             # Windows one-click bootstrap
├── OPEN_ARTIFACTS.cmd         # Windows docs launcher
├── PROJECT_STRUCTURE.md       # This file
├── DEV.md                     # Developer workflow
│
├── .gitignore
├── .editorconfig
├── .env.example
├── .prettierrc
├── .nvmrc
├── package.json               # (if Node/TS project)
├── pnpm-workspace.yaml        # (if monorepo)
├── pyproject.toml             # (if Python project)
├── tsconfig.base.json
├── docker-compose.yml         # Dev compose (minimal)
├── docker-compose.prod.yml    # Prod compose (full orchestration)
└── LICENSE
```

## Where to put things

| When you're adding... | Put it in... |
|---|---|
| A new backend route | `apps/api/src/routes/` or `src/routes/` |
| A new frontend page | `apps/web/src/pages/` or `src/pages/` |
| A reusable UI component | `apps/web/src/components/` or `src/components/` |
| A domain schema (Zod / Pydantic) | `packages/shared/schemas/` or `src/schemas/` |
| A new enum or state machine | `packages/shared/state/` |
| A utility function | `apps/{web,api}/src/lib/` or `src/lib/` |
| A type definition | `packages/shared/types/` or `src/types/` |
| A test | `tests/{unit,integration,e2e}/` mirroring source path |
| A new Claude subagent | `agents/<name>.md` |
| A new skill | `skills/<name>/SKILL.md` |
| A new slash command | `commands/<name>.md` |
| A new hook handler | `hooks/` + register in `hooks/hooks.json` |
| A new MCP server config | `mcp-configs/mcp-servers.json` (template) |
| A new ADR | `docs/04-quality/adr/NNNN-title.md` (increment number) |
| A new runbook | `docs/03-deployment/RUNBOOK.md` (or new file in same folder) |
| A bootstrap script | `01_setup/` (read by `run.ps1`/`run.sh`) |
| A one-off ops script | `04_tools/<name>.{ps1,sh}` |
| Pre-build / source assets | `assets-source/` (consider git-ignoring large files) |

## Monorepo vs single-app decision

The init script makes this choice for you based on `-Stack`:

| Stack | Layout |
|---|---|
| `node` | Monorepo: `apps/` + `packages/`. No `src/`. |
| `hybrid` | Both monorepo AND single-app present (default). Pick one and delete the other. |
| `python` | Single-app: `src/<package>/`. No `apps/`. No `packages/`. |
| `docs` | No source dirs at all. |

**Use monorepo (`apps/` + `packages/`)** when:
- You have >= 2 deployable services sharing types
- You need to share schemas / state machine / enums between frontend and backend
- You expect to grow to >= 3 packages

**Use single-app (`src/`)** when:
- One deployable artifact
- No shared types between processes
- Want minimum ceremony

If you started with `hybrid` and want to commit: `git rm -r apps packages` OR `git rm -r src`. Don't keep both — it confuses contributors and grep results.
