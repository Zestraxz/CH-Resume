# Phase 1 — Scaffold

**Period:** YYYY-MM-DD → YYYY-MM-DD
**Goal:** Stand up the repository skeleton with conventions, governance, and one-click bootstrap.
**Exit criteria:** `START_HERE.cmd` runs clean on a fresh clone. CI green on an empty PR.

---

## Done

- [x] Lifecycle folders (`01_setup` → `05_archive`)
- [x] Docs tree (`docs/00-99`)
- [x] `CLAUDE.md` + `AGENTS.md` + `.github/copilot-instructions.md`
- [x] `STATUS.md` with phase matrix
- [x] `.gitignore`, `.editorconfig`, `.env.example`, `.prettierrc`, `.nvmrc`
- [x] `tsconfig.base.json` strict
- [x] `docker-compose.yml` + `docker-compose.prod.yml`
- [x] `START_HERE.cmd` + `OPEN_ARTIFACTS.cmd` Windows launchers

## In progress

- [ ] `01_setup/run.ps1` + `run.sh` bootstrap scripts
- [ ] CI workflow (`.github/workflows/ci.yml`)
- [ ] Sample `apps/api` + `apps/web` + `packages/shared` stubs

## Blocked

_None._

## Notes

- Choice to default to pnpm workspaces over npm/yarn — see [../docs/04-quality/adr/0002-package-manager.md](../docs/04-quality/adr/0002-package-manager.md).
- Choice to keep `src/` AND `apps/` directories in template (delete one when you instantiate) — gives flexibility without forcing a monorepo decision upfront.

## Phase 1 → Phase 2 handoff

When Phase 1 ships, move this file to `03_history/PHASE1_NOTES.md` and create `PHASE2_NOTES.md`.
