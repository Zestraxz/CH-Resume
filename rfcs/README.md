# rfcs/ - Request for Comments

> Discussion documents. Output: an accepted RFC + an ADR capturing the final decision.

---

## When to write an RFC vs an ADR

| | RFC | ADR |
|---|---|---|
| Purpose | Discussion (multiple options, debate) | Record (one decided outcome) |
| Lifecycle | Active -> Accepted/Rejected/Withdrawn | Proposed -> Accepted -> (Superseded) |
| Location | `rfcs/active/`, `rfcs/accepted/`, `rfcs/rejected/` | `docs/04-quality/adr/NNNN-title.md` |
| Numbering | Incrementing within `rfcs/` | Strict sequential numbering |

## Flow

1. Copy `0000-template.md` to `active/NNNN-short-title.md`.
2. Open PR. Discuss in PR comments.
3. After consensus:
   - **Accepted:** move to `accepted/`. Create an ADR capturing the decision.
   - **Rejected:** move to `rejected/` with a one-line summary at the top explaining why.
   - **Withdrawn:** move to `rejected/` (or delete).

## Inspiration

Rust, Ember, React, Stripe, Glovo, LinkedIn all use this pattern.

- [Rust RFCs](https://github.com/rust-lang/rfcs)
- [Pragmatic Engineer - Scaling Engineering Teams via RFCs](https://blog.pragmaticengineer.com/scaling-engineering-teams-via-writing-things-down-rfcs/)
