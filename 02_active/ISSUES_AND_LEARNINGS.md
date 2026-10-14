# Resume — Issues & Learnings

> Append-only log of pitfalls hit, decisions reversed, and gotchas found.
> **Read this before debugging anything weird.**
> Each entry has an ID (`I-XXX`) so you can reference it from commit messages and ADRs.

---

## Template for new entries

```markdown
### I-XXX — Short title
**Date:** YYYY-MM-DD
**Phase:** N
**Severity:** Low / Med / High / Blocker
**Status:** Open / Resolved (commit `<sha>`)

**Symptom:**
What you observed.

**Root cause:**
What was actually wrong.

**Fix:**
What we did.

**Prevention:**
How we keep this from biting again (test, lint rule, ADR, docs).

**See also:**
- ADR-NNNN if applicable
- Related I-XXX
```

---

## Entries

### I-001 — Example: Mocked tests passed but prod migration failed
**Date:** YYYY-MM-DD
**Phase:** 2
**Severity:** High
**Status:** Resolved (commit `<sha>`)

**Symptom:**
Integration tests for migration `0042_add_user_status` green in CI; deploy to staging dropped a column.

**Root cause:**
Tests used SQLite mock; prod is Postgres. SQLite silently accepted `ALTER TABLE ... DROP COLUMN`; Postgres requires `CASCADE` and the migration didn't include it.

**Fix:**
Added `CASCADE` to the migration. Switched integration test DB to a real Postgres container via testcontainers.

**Prevention:**
- ADR-0007: "Integration tests run against real Postgres, not SQLite mocks."
- CI now spins up postgres:16-alpine for `pnpm test:integration`.

**See also:**
- ADR-0007
- `docs/04-quality/adr/0007-postgres-integration-tests.md` (scaffold template ADR; never created in this repo)

---

_(Append new entries below this line — newest at the bottom.)_
