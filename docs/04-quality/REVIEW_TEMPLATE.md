# Review Template

> Use this when conducting a deliberate review (critic agent, periodic audit, pre-release check).

---

## Metadata

- **Reviewer:** {{REVIEWER}}
- **Date:** YYYY-MM-DD
- **Scope:** {{e.g. "PR #42", "v0.3.0 release candidate", "Q1 codebase audit"}}
- **Commit SHA:** `<sha>`

## Review dimensions

### 1. Correctness

| Question | Answer |
|---|---|
| Does the code do what the PR / spec says? | ✅ / ⚠️ / ❌ |
| Are edge cases covered (empty, null, max, concurrent)? | ✅ / ⚠️ / ❌ |
| Are error paths handled (not just happy path)? | ✅ / ⚠️ / ❌ |
| Do tests actually test the new behavior? | ✅ / ⚠️ / ❌ |

### 2. Maintainability

| Question | Answer |
|---|---|
| Will a stranger understand this in 6 months? | ✅ / ⚠️ / ❌ |
| Are names clear (no `data`, `info`, `process`)? | ✅ / ⚠️ / ❌ |
| Is there a `TODO` / `FIXME` that should be an issue? | ✅ / ⚠️ / ❌ |
| Is there dead code, commented-out blocks, unused imports? | ✅ / ⚠️ / ❌ |

### 3. Architecture fit

| Question | Answer |
|---|---|
| Does it follow conventions in [../../CLAUDE.md](../../CLAUDE.md)? | ✅ / ⚠️ / ❌ |
| Does it respect domain boundaries (no shortcuts across layers)? | ✅ / ⚠️ / ❌ |
| If it changed architecture, is there an ADR? | ✅ / ⚠️ / ❌ |

### 4. Security

| Question | Answer |
|---|---|
| All user input validated at boundary (Zod / Pydantic)? | ✅ / ⚠️ / ❌ |
| Any secrets / API keys leaked into source? | ✅ / ⚠️ / ❌ |
| Any SQL built by string concatenation? | ✅ / ⚠️ / ❌ |
| Any logged data that's PII? | ✅ / ⚠️ / ❌ |

### 5. Performance

| Question | Answer |
|---|---|
| Any N+1 queries? | ✅ / ⚠️ / ❌ |
| Any unbounded loops / queries? | ✅ / ⚠️ / ❌ |
| Any sync I/O that should be async? | ✅ / ⚠️ / ❌ |
| Any large objects held in memory unnecessarily? | ✅ / ⚠️ / ❌ |

### 6. Testing

| Question | Answer |
|---|---|
| Are tests fast (< 100ms for unit)? | ✅ / ⚠️ / ❌ |
| Are tests deterministic (no time, no random, no network)? | ✅ / ⚠️ / ❌ |
| Are they testing behavior, not implementation? | ✅ / ⚠️ / ❌ |
| Does coverage match team minimum ({{COVERAGE_MIN}}%)? | ✅ / ⚠️ / ❌ |

### 7. Documentation

| Question | Answer |
|---|---|
| Public APIs documented (JSDoc / docstrings)? | ✅ / ⚠️ / ❌ |
| New conventions added to CLAUDE.md? | ✅ / ⚠️ / ❌ |
| CHANGELOG updated? | ✅ / ⚠️ / ❌ |
| If user-facing: docs updated? | ✅ / ⚠️ / ❌ |

## Findings

### Must fix (blocks merge)
- _(list)_

### Should fix (before next phase)
- _(list)_

### Nice to have (track as issue)
- _(list)_

## Verdict

- [ ] ✅ Approved
- [ ] ⚠️ Approved with comments (please address)
- [ ] ❌ Changes requested

## Add to ledger

Once complete, summarize one line in [REVIEW_LEDGER.md](REVIEW_LEDGER.md).
