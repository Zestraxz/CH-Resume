# 0001 — Record Architecture Decisions

**Status:** Accepted
**Date:** YYYY-MM-DD
**Deciders:** Chan Hoe

---

## Context

We need a lightweight way to record architecture decisions so that:

- New contributors can understand *why* the codebase looks the way it does
- We don't accidentally re-decide the same question in different ways
- We have a forensic trail when a decision is later reversed

## Decision

We will use **Architecture Decision Records (ADRs)** in the [Michael Nygard format](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions).

- Each ADR is a numbered markdown file in `docs/04-quality/adr/`.
- Filename: `NNNN-short-kebab-title.md` (e.g., `0007-postgres-integration-tests.md`).
- Numbering is sequential, never reused, never gapped.
- Each ADR has the following sections:
  - `Status` (Proposed / Accepted / Rejected / Superseded by ADR-NNNN)
  - `Date`
  - `Deciders`
  - `Context` (the forces at play)
  - `Decision` (what we're doing)
  - `Consequences` (positive, negative, neutral)

## Consequences

### Positive
- Decisions are discoverable in one place
- Discussion happens in PR comments and is preserved
- New contributors can read the ADR list to onboard

### Negative
- Discipline required to write them (easy to skip "obvious" decisions)
- Risk of ADR-drift (decisions made but not recorded)

### Neutral
- ADRs are advisory documentation, not enforcement — the code is the truth.

## Process

1. Copy this file → `NNNN-your-title.md` (increment number).
2. Set `Status: Proposed`.
3. Open a PR with the ADR.
4. Discuss in PR comments.
5. Maintainer marks `Status: Accepted` or `Status: Rejected` before merging.
6. To reverse a decision: write a new ADR; mark the old one `Status: Superseded by ADR-NNNN`.

## See also

- [Michael Nygard, "Documenting Architecture Decisions"](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [adr.github.io](https://adr.github.io/) — community templates
