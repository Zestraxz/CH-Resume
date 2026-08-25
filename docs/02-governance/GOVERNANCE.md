# Governance — Resume

> How decisions are made, who decides, how long it should take.

---

## Roles

| Role | Who | What |
|---|---|---|
| **Maintainer** | Chan Hoe | Approves all PRs; owns roadmap; final call on architecture |
| **Reviewer** | Designated per area (CODEOWNERS) | Reviews PRs in their area; can approve |
| **Contributor** | Anyone with PR access | Submits PRs; follows [CONTRIBUTING.md](CONTRIBUTING.md) |
| **User** | Anyone using the project | Files issues, requests features |

## Decision thresholds

| Decision type | Required approvals | SLA |
|---|---|---|
| Trivial (typos, formatting, docs only) | 1 maintainer | 1 business day |
| Routine (feature, fix, refactor within existing architecture) | 1 maintainer | 5 business days |
| Schema / contract change (breaks consumers) | 1 maintainer + 1 reviewer | 7 business days |
| Architecture change (new stack, new service, pattern shift) | Maintainer + ADR with majority of reviewers | 14 business days |
| Governance change (this file, CODEOWNERS, CLAUDE.md) | Maintainer | 14 business days |

## ADR process

For any decision that:
- Changes the stack
- Adds a load-bearing dependency
- Changes a public contract (API, schema, event shape)
- Establishes a convention people must follow
- Reverses a prior decision

Open an ADR. Template: [../04-quality/adr/0001-record-architecture-decisions.md](../04-quality/adr/0001-record-architecture-decisions.md).

Process:
1. Copy template → new number.
2. Open PR with ADR + (optionally) supporting code.
3. Discuss in PR comments.
4. Maintainer marks `Status: Accepted` or `Status: Rejected`.
5. If Accepted, the ADR is binding until superseded by a later ADR.

## Conflict resolution

1. Try to resolve in PR comments / channel discussion.
2. If stuck for > 3 business days, escalate to maintainer.
3. Maintainer's decision is final but must be recorded as an ADR with rationale.

## Decision log

All accepted ADRs live in [../04-quality/adr/](../04-quality/adr/). Read them before proposing changes in adjacent areas.

## Changing this document

This document itself follows the "Governance change" decision rules above. Open an ADR.
