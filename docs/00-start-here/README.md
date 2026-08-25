# 00 Start Here

> The first 30 minutes on this project.

---

## Reading sequence

1. [QUICKSTART.md](QUICKSTART.md) — get the app running in 5 minutes
2. [INSTALL.md](INSTALL.md) — proper install when QUICKSTART isn't enough
3. [../../README.md](../../README.md) — project overview
4. [../../STATUS.md](../../STATUS.md) — where the project is right now
5. [../../02_active/ARCHITECTURE.md](../../02_active/ARCHITECTURE.md) — how it's built
6. [../../02_active/ISSUES_AND_LEARNINGS.md](../../02_active/ISSUES_AND_LEARNINGS.md) — gotchas
7. [../../CLAUDE.md](../../CLAUDE.md) — AI workflow conventions

## Common tasks

- **Run locally:** `START_HERE.cmd` (Windows) or `./01_setup/run.sh` (Unix)
- **Open docs:** `OPEN_ARTIFACTS.cmd` (Windows)
- **Run tests:** `pnpm test`
- **Format + lint + typecheck:** `pnpm precommit`
- **Create an ADR:** copy `../04-quality/adr/0001-*.md` → new number

## If you're stuck

1. Check [../../02_active/ISSUES_AND_LEARNINGS.md](../../02_active/ISSUES_AND_LEARNINGS.md) — someone may have hit this already.
2. Check [../03-deployment/RUNBOOK.md](../03-deployment/RUNBOOK.md) for service-level issues.
3. Search the codebase (`pnpm grep <term>` or `rg <term>`).
4. Open an issue with the [bug template](../../.github/ISSUE_TEMPLATE/bug.md).
