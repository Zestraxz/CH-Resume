# Resume — Roadmap

> Phases, milestones, dependencies. Updated as the project moves.

---

## Now / Next / Later

### Now (this week / sprint)
- {{NOW_ITEM_1}}
- {{NOW_ITEM_2}}

### Next (1–4 weeks)
- {{NEXT_ITEM_1}}
- {{NEXT_ITEM_2}}

### Later (1–6 months)
- {{LATER_ITEM_1}}
- {{LATER_ITEM_2}}

---

## Phases

### Phase 1 — Scaffold
**Goal:** Repo skeleton, conventions, bootstrap.
**Exit criteria:** `START_HERE.cmd` runs clean on a fresh clone. CI green on empty PR.

### Phase 2 — Domain model
**Goal:** Schemas, enums, state machine live in `packages/shared/`. DB migrations in place.
**Exit criteria:** Schema covers all entities in [ARCHITECTURE.md §3](ARCHITECTURE.md#3-components). Migrations forward-only, reversible.

### Phase 3 — MVP
**Goal:** Smallest end-to-end path from frontend → API → DB → frontend works.
**Exit criteria:** One happy-path user journey demoable. ≥1 integration test green.

### Phase 4 — Polish
**Goal:** Error handling, validation, observability, tests at 70% coverage.
**Exit criteria:** Sentry catches errors. Logs structured. Coverage report ≥ target.

### Phase 5 — Production
**Goal:** Deploy to prod with monitoring, backups, runbook.
**Exit criteria:** [docs/03-deployment/RUNBOOK.md](../docs/03-deployment/RUNBOOK.md) complete. Healthchecks green for 7 days.

---

## Dependencies

| Phase | Depends on | Blocks |
|---|---|---|
| 2 | 1 | 3, 4 |
| 3 | 2 | 4 |
| 4 | 3 | 5 |
| 5 | 4 | — |

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| {{RISK_1}} | Med | High | {{MITIGATION_1}} |
| {{RISK_2}} | Low | Med | {{MITIGATION_2}} |

---

## Out of scope

Explicit non-goals (in case stakeholders ask):

- {{NON_GOAL_1}}
- {{NON_GOAL_2}}
