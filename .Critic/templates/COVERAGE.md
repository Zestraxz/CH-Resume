# Coverage Map — Self-Critic ({{PROJECT}})

> **This file is the Radar's memory.** A scheduled run starts with zero context; everything it knows
> about what has already been swept, tried, or ruled out, it learns here. Keep it current or the
> Radar re-proposes dead ideas.
>
> Bound from `.Critic/Critic-Radar.md` → *Project binding*. Companion: `REFUTED-LEDGER.md`.
>
> 🔧 **SEEDED STUB — edit before the first scheduled run.** Replace §B/§C/§D with this project's real
> areas. An unedited stub makes the Radar sweep a fictional surface, which is worse than not running.

- **Repo:** {{REPO}}
- **Created:** {{DATE}}
- **Cadence:** weekly — see `SOP-AUTONOMOUS-SELF-CRITIC.md`
- **Bar:** ≥ 90 adjudicated, zero open CRITICAL/MAJOR (`.Critic/Critic-Agent-Loop.md`)
- **Provability floor:** *(TODO — the smallest effect this project can actually measure. If none
  applies, write "none" explicitly; a blank invites the Radar to invent one.)*

---

## §A — What this project is (so a zero-context agent can orient)

*(TODO: 3–6 lines. What it does, who uses it, what "good" means here. A zero-context agent reads only
this to build its mental model — vagueness here degrades every finding downstream.)*

---

## §B — Coverage matrix

Status: ✅ covered/verified · 🟡 partial · ❌ untried · 🚫 ruled out (→ ledger)

| # | Layer | Area | Status | Evidence / note |
|---|---|---|---|---|
| B1 | {{LAYER1}} | *(TODO)* | ❌ | |
| B2 | {{LAYER1}} | *(TODO)* | ❌ | |
| B3 | {{LAYER2}} | *(TODO)* | ❌ | |
| B4 | scheduling | Scheduler has fired end-to-end at least once | ❌ | Prove it — SOP §4 |
| B5 | portability | Binding section edited for this project | ❌ | `.Critic/Critic-Radar.md` bottom |

---

## §C — Ranked backlog (expected value / cost)

| # | Finding | Layer | Cheapest first measurement | Nearest refuted class + distinction |
|---|---|---|---|---|
| C1 | Binding + coverage map are unedited stubs, so the Radar has no real surface to sweep. | portability | Fill §A/§B/§D and the binding section | None — setup debt. |
| C2 | Scheduler installed but never fired. | scheduling | One manual `workflow_dispatch` run | **L-ONDEMAND**. Distinction: this is its *fix*, unverified — not a re-proposal. |

---

## §D — Layer definitions

*(TODO: name this project's layers. The layer check is the Radar's sharpest tool — mature projects
over-generalise their laws, and an entire untouched layer can hide behind a rule borrowed from
elsewhere. Pick layers that could each independently be the place nobody has looked.)*

| Layer | What lives here | Never-tried question to ask each run |
|---|---|---|
| {{LAYER1}} | *(TODO)* | *(TODO)* |
| {{LAYER2}} | *(TODO)* | *(TODO)* |
| {{LAYER3}} | *(TODO)* | *(TODO)* |

> **Layer rule:** a hard-won rule in one layer must not veto another.

---

## §E — Reports

> Newest first. Each scheduled run appends one dated block (≤60 lines). Human triage rejections stay
> here **with reasons** — the next run reads them and must not re-raise without new evidence.

### {{DATE}} — Setup (baseline, not a Radar run)

Self-Critic kit installed and bound to {{PROJECT}}. No sweep has run yet.

**Executive summary (5 lines):**
1. *Best new opportunity:* n/a — no sweep yet.
2. *Most dangerous gap:* the binding and this map are unedited stubs (**C1**).
3. *Most dangerous over-broad claim:* none recorded yet.
4. *Now obsolete in the queue:* n/a.
5. *Recalibrate:* set a real provability floor after run 3.
