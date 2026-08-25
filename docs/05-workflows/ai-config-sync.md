# Workflow - AI Config Sync

> When you edit AGENTS.md, the pointer files (CLAUDE.md, copilot-instructions.md, .cursor/rules/, .windsurfrules) may drift. This workflow keeps them aligned.

---

## TL;DR

AGENTS.md is the source of truth. The pointer files are 3-5 lines and rarely change. Just verify on every AGENTS.md edit that pointers still point correctly.

## Checklist after editing AGENTS.md

- [ ] `CLAUDE.md` still says "read AGENTS.md"
- [ ] `.github/copilot-instructions.md` still says "read ../AGENTS.md"
- [ ] `.cursor/rules/always.mdc` references AGENTS.md correctly
- [ ] `.windsurfrules` and `.aider.conf.yml` still point at AGENTS.md
- [ ] No drift in directory-scoped sub-AGENTS.md (`packages/shared/AGENTS.md`, `apps/api/AGENTS.md`, `apps/web/AGENTS.md`) - those have narrower scopes by design

## Symlink alternative (Unix/Mac)

On Unix systems with symlink-aware tooling:

```bash
ln -sf AGENTS.md CLAUDE.md
ln -sf ../AGENTS.md .github/copilot-instructions.md
```

Don't do this on Windows unless dev-mode symlinks are enabled - some tooling breaks.

## Auto-sync (future work)

`ai-config-sync` is an emerging tool that maintains the fan-out from a single source. Not yet stable enough to bake into the template - re-evaluate at the next 6-month BENCHMARK review.
