# /critic — Critic-Agent loop (command body)

> This is the procedure the `/critic` slash command runs. The thin launcher at
> `.claude/commands/critic.md` just points here. Run this on the target you were given.
> **`Critic-Agent-Loop.md` is canonical for the loop's rules** — this file is its operational
> summary; on any conflict, the Loop file wins.

You are running the **Critic-Agent improvement loop** on the target passed to `/critic`.
If no target was given, default to the **current working-tree changes** (`git diff` + new files) — i.e.
"harden what I just changed". Parse an optional pass **bar** from the arguments (a number like `85`);
default **overall ≥ 90 / 100** (a parameter — see *Calibration* in `Critic-Agent-Loop.md`).

## Authoritative sources — read these first
Read **`.Critic/Critic Agent 1.txt`** (the 7-dimension scoring rubric + output JSON) and
**`.Critic/Critic-Agent-Loop.md`** (the loop, stop conditions, guardrails) and follow them exactly.
If either is missing, the self-contained steps below are the fallback.

## The loop (repeat until a stop condition fires)
1. **Score — INDEPENDENTLY.** Spawn **2–3 fresh-context critic sub-agents in parallel** (Agent tool,
   `general-purpose`), each with a **different named lens** (always include FIDELITY when the target
   asserts facts from sources — see the rubric's Panel Composition). Give each ONLY: (a) "read
   `.Critic/Critic Agent 1.txt` — that is your rubric"; (b) the target + exactly which files to read +
   the assigned lens; (c) "return the Critic Agent JSON; do NOT modify files; do NOT inflate". They
   must **not** see any prior score or your own assessment.
2. **Verify, adjudicate, aggregate.** Check every factual claim in every finding against the primary
   sources (figures: check basis — period / denominator / scope). Strike failed findings into a
   `refuted` ledger with evidence; if a panelist's dimension scores rest materially on refuted
   findings, a fresh-context critic (never you) re-derives them from the surviving evidence. The
   verdict = the **minimum** `overall_score` across the panel **after this adjudication**.
3. **Stop?** DONE = adjudicated verdict `>= bar` **and** zero verified CRITICAL/MAJOR findings open —
   the only valid way to terminate as "passed".
4. **Fix every VERIFIED finding.** CRITICAL first, down to NITPICK. Wrong findings → `refuted`;
   valid-but-harmful / out-of-mandate / owner-dependent findings → `not_actioned` with rationale.
   Implementing an unverified finding is itself a defect. Verify each change the way this repo
   verifies (syntax-check, run the script, or browser-check per its norms).
5. **Audit the fixes.** An independent fresh-context critic audits the change list + the `refuted` ledger against the primary
   sources — each change for regressions (CONFIRMED / REGRESSION) and each refutation spot-checked
   (refuting a valid finding is the loop's main gaming vector). The author's fixes and strikes get the
   same scrutiny as the critics' claims.
6. **Log** the pass to `_runs/critic_<slug>_pass<N>.json` (overall, per-dimension scores, the three
   ledgers, fix-audit result, delta). `_runs/` is git-ignored scratch.
7. **Re-score** the changed artifact (back to step 1).

## Stop conditions (any one ends the loop)
- ✅ **Cleared** — adjudicated verdict `>= bar`, zero open CRITICAL/MAJOR, independently confirmed.
- 🔁 **Max 5 passes** — report the best score + what remains.
- 📉 **Plateau** — two consecutive passes gain `< +1` point (near a plateau, weigh surviving-finding
  counts, not the score alone — deltas include panel-resampling noise).
- 🛑 **Would-harm** — the only remaining way to raise the score degrades the artifact (breaks
  functionality, correctness, or an external contract). Stop and report an honest lower score; do not
  make the change.
- ⚠ **Regression signal** — a pass scoring below its predecessor triggers a fix-audit of the last
  batch before continuing.

## Guardrails — non-negotiable (this is self-scoring, and the judge is fallible)
- You are the **fixer**, never the **judge**. Every score comes from the independent sub-agents.
- Score honestly to the rubric; **never inflate to terminate**. An honest, defensible **88** beats a
  gamed **96**.
- **Critic findings are claims, not facts** — verify before acting. **Your fixes are changes, not
  improvements** — audit them. Both directions, every pass.
- **Never degrade the artifact to clear the bar.** If reaching it needs a harmful, owner-dependent, or
  out-of-constraint change, stop and report it instead of doing it.
- The final reported score must describe the **shipped artifact** — label post-measurement changes
  **UNMEASURED**; CRITICAL/MAJOR ones trigger one more confirming pass.
- This loop needs the model every pass — it is an **in-session** task, NOT VPS-detachable (only heavy
  *data* sub-steps can detach; see `../Detached-Long-Jobs-Runbook.md` if present).

## Output
A short ledger per pass — `pass # → adjudicated verdict → verified/refuted/not_actioned counts → top
changes → fix-audit result → delta` — ending in **cleared (with the confirming independent score)** or
**stopped — why**. Commit the fixes per the repo's conventions (one commit per pass is fine); push only
if the repo's workflow expects it.
