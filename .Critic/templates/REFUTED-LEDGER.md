# Refuted-Approaches Ledger — {{PROJECT}}

> **This file is the Radar's discipline.** Before proposing anything, a run must check this ledger and
> name the **nearest failed class** plus the **distinction** that makes its proposal different. A
> critic that re-proposes dead ideas is worse than no critic.
>
> Bound from `.Critic/Critic-Radar.md` → *Project binding*. Companion: `COVERAGE.md`.

## How to use this file

- **Laws are not permanent.** A law is refuted *for a stated class of change*, on *stated evidence*.
  A proposal may defeat a law — but only by explicitly addressing that evidence.
- **Scope matters more than the verdict.** Read the class, not the headline.
- **Append, never rewrite.** Superseded laws get a `SUPERSEDED BY` line, not a deletion.

| Field | Meaning |
|---|---|
| **Class** | The class of change this refutes — the reusable part |
| **Evidence** | `field` = observed in real runs · `constraint` = operator/environment limit · `verified` = checked directly |
| **Defeat condition** | What a future proposal must show to overturn it |

---

## Laws inherited from the kit (portable — keep these)

These came from the Critic kit's own field logs and apply to **any** project running it.

### L-BAR — a bar that never binds
- **Class:** setting the pass bar above the rubric's own "ready" band (kit shipped at `> 95`).
- **Verdict:** 🚫 Refuted. **Evidence:** `field` — 11 logged runs, best honest score **89**; the bar
  never bound, so every loop ended on a stop condition.
- **Now law:** bar = **≥ 90** *and* zero open CRITICAL/MAJOR.

### L-ONDEMAND — the on-demand-only critic
- **Class:** relying on a human to point the critic at a target.
- **Verdict:** 🚫 Refuted. **Evidence:** `field` — three program-critical gaps surfaced only when a
  human happened to ask.
- **Now law:** discovery runs **on a schedule**. Corollary: *an installed-but-never-fired scheduler is
  this same failure wearing a costume.*

### L-TRUST — critic findings treated as facts
- **Class:** acting on a recommendation without verifying it against primary sources.
- **Verdict:** 🚫 Refuted. **Evidence:** `field` — roughly **a quarter to a third** of critic
  recommendations did not survive verification.
- **Now law:** findings are **claims, not facts**. Verify, then act.

### L-NOAUDIT — author fixes trusted unaudited
- **Class:** treating the author's own fixes as improvements without independent regression audit.
- **Verdict:** 🚫 Refuted. **Evidence:** `field` — **two author-introduced regressions** were caught
  only by a confirming pass.
- **Now law:** audit every fix batch **and** spot-check the author's refutations.

### L-SELFJUDGE — author also grades
- **Class:** the agent that fixes an artifact also scoring it.
- **Verdict:** 🚫 Refuted (structural). **Evidence:** `field` — gameable by construction.
- **Now law:** all scoring by fresh-context sub-agents; the author only ever *fixes*.

### L-UNBOUNDED — the unbounded critic
- **Class:** discovery runs without caps on searches, report length, or iterations.
- **Verdict:** 🚫 Refuted. **Evidence:** `field` — an unbounded critic becomes the cost center it was
  meant to catch.
- **Now law:** ≤ 8 searches · ≤ 60-line report · exactly one Mode-B pass per scheduled run.

---

## Laws specific to {{PROJECT}}

> 🔧 Add this project's own refuted classes here as they are established. Each needs: class, verdict,
> evidence, resulting law, defeat condition. **Without these the Radar has no local discipline** and
> will keep re-proposing things this project already tried and abandoned.

*(none yet)*

---

## Rejected findings (human triage)

> Findings a human reviewed and declined, **with reasons**. The next Radar run reads this and must not
> re-raise them without new evidence. Rejections are context, not garbage.

| Date | Finding | Rejected because | Re-raise if |
|---|---|---|---|
| — | *(none yet)* | — | — |
