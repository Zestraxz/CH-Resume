# Error Budget Policy

> What we do when the SLO budget is exhausted.

---

## Budget mechanics

- SLO target: 99.5% over 30d.
- Error budget = 100% - 99.5% = 0.5% = ~3.6 hours of unavailability per 30d.
- "Budget consumed" = downtime so far in current 30d window.
- "Burn rate" = consumption rate vs. linear ideal.

## Stages

### Stage 1: 0-50% budget consumed
**Status:** Green. Feature work proceeds normally.

### Stage 2: 50-80% budget consumed
**Status:** Yellow. Slow burn alert fires; on-call ticketed.

**Actions:**
- Investigate top contributors to error rate.
- Defer non-critical migrations / risky deploys to next window.
- Add reliability work to the backlog (don't displace it).

### Stage 3: 80-100% budget consumed
**Status:** Red. Fast burn alert fires; page on-call.

**Actions:**
- **Feature freeze.** No new feature deploys until burn rate < 1x.
- All eng capacity to reliability work until budget restored.
- Post-incident review (PIR) for the consuming incidents.

### Stage 4: > 100% (budget exhausted)
**Status:** Critical. SLO is broken.

**Actions:**
- Full freeze including bugfixes that aren't reliability-related.
- Incident commander assigned.
- Mandatory PIR with leadership review.
- Re-evaluate SLO: was it too aggressive? Realistic for current architecture? Don't lower silently; ADR-document.

## Window reset

The 30d window is rolling - budget recovers as the consuming incident ages out. This is not a calendar quarter reset.

## Escalation

| Stage | Notified | SLA |
|---|---|---|
| Yellow | on-call (ticket) | 1 business day to acknowledge |
| Red | on-call (page) | 1 hour to acknowledge; freeze announcement in 4 hours |
| Critical | leadership (email + page) | immediate freeze; PIR within 5 business days |

## Exception process

To deploy during freeze:

1. Reliability impact assessment documented (one paragraph).
2. Two-person review (proposer + maintainer).
3. Reversibility plan documented (one paragraph).
4. PIR scheduled if deploy fails.

No silent overrides.

## References

- [Google SRE - Error Budget Policy](https://sre.google/workbook/error-budget-policy/)
