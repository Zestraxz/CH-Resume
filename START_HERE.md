# START HERE → Resume

> Cold-reader onboarding. If you're new here (human, AI, or future-you), start at the top.

---

## 1. What this is

TODO: paragraph describing Resume

**Current state:** see [STATUS.md](STATUS.md).

## 2. Run it in 30 seconds

**Windows:**
```cmd
.\START_HERE.cmd
```

**Bash:**
```bash
./01_setup/run.sh
```

The bootstrap script will:
1. Check prerequisites (Node, Python, Docker as applicable).
2. Create `.env` from `.env.example` if it doesn't exist.
3. Install dependencies.
4. Bring up Docker services.
5. Wait for healthchecks.
6. Open the app in your browser.

## 3. Reading sequence

| # | File | Why |
|---|---|---|
| 1 | [STATUS.md](STATUS.md) | What phase the project is in, what's blocked |
| 2 | [README.md](README.md) | Stack, layout, quickstart |
| 3 | [02_active/ARCHITECTURE.md](02_active/ARCHITECTURE.md) | How it's built |
| 4 | [02_active/ROADMAP.md](02_active/ROADMAP.md) | Where it's going |
| 5 | [02_active/ISSUES_AND_LEARNINGS.md](02_active/ISSUES_AND_LEARNINGS.md) | Pitfalls to avoid |
| 6 | [CLAUDE.md](CLAUDE.md) | AI assistant conventions (also human-useful) |
| 7 | [docs/02-governance/CONTRIBUTING.md](docs/02-governance/CONTRIBUTING.md) | How to contribute |
| 8 | [docs/03-deployment/RUNBOOK.md](docs/03-deployment/RUNBOOK.md) | When something breaks |

## 4. Folder map

```
01_setup/      → Bootstrap. Run me first.
02_active/     → Current phase notes, architecture, roadmap. Edit me.
03_history/    → Read-only past snapshots. Don't touch.
04_tools/      → Ops automation. Refactor cautiously.
05_archive/    → Locked legacy. Don't touch.

apps/          → Runnable apps (monorepo).
packages/      → Shared libs (monorepo).
src/           → Single-app source (if not monorepo).
tests/         → Test suite.

docs/          → Numbered docs (00-99).
scripts/       → Lifecycle scripts.

.claude/       → Claude Code config.
agents/        → Custom subagents.
skills/        → Skills.
commands/      → Slash commands.
hooks/         → Hooks (declarative).
mcp-configs/   → MCP server templates.
rules/         → Layered AI rules.

.github/       → CI/CD workflows.
```

## 5. .cmd launchers

| Launcher | What it does |
|---|---|
| `START_HERE.cmd` | Bootstrap + start everything + open browser |
| `OPEN_ARTIFACTS.cmd` | Open README, docs, and key URLs |

Double-click on Windows, or call from CMD/PowerShell.

## 6. Common operations

```bash
# Run all tests
pnpm test

# Format + lint + typecheck
pnpm precommit

# Reset local DB
.\scripts\03-database\reset.ps1

# Push a commit safely
.\04_tools\GitPush.ps1 -Message "feat: ..."
```

## 7. When you're lost

- **Where do I put X?** Check [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md).
- **Why is X built this way?** Check [docs/04-quality/adr/](docs/04-quality/adr/) for the ADR.
- **What was tried before that didn't work?** Check [02_active/ISSUES_AND_LEARNINGS.md](02_active/ISSUES_AND_LEARNINGS.md).
- **Service won't start?** Check [docs/03-deployment/RUNBOOK.md](docs/03-deployment/RUNBOOK.md).

## 8. When something is genuinely new

Open an ADR: copy [docs/04-quality/adr/0001-record-architecture-decisions.md](docs/04-quality/adr/0001-record-architecture-decisions.md), increment the number, fill in the decision.
