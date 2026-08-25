# Critic Agent — iterative improvement loop (to a calibrated bar; default ≥ 90)

> Companion to **`Critic Agent 1.txt`** (its sibling in this `.Critic/` folder — from the repo root,
> `.Critic/Critic Agent 1.txt`). That file is the *evaluator* (one 7-dimension scored pass); this file
> defines how to *run it as a loop*: evaluate → verify → act on verified findings → audit the fixes →
> re-evaluate → repeat until the work clears the bar. **Portable** — drop the whole `.Critic/` folder
> into any repo. **This file is canonical for the loop's rules**; `critic.command.md` is its
> operational summary and defers to it on any conflict.
>
> **Trigger:** "Apply Critic Agent 1.txt and take action on all recommendations" means run **this loop**,
> not a single evaluation. Default bar: **overall ≥ 90 / 100** (see *Calibration*, below).

## The loop
0. **Target & bar.** Name the artifact under review (a doc, a module, a data model, a column…) and the bar (default **≥ 90**).
1. **Evaluate — independently.** Spawn **2–3 fresh-context critic sub-agents in parallel**, each with a
   DIFFERENT named lens (see the rubric's *Panel Composition*; always include FIDELITY when the target
   asserts facts from sources). Each returns the full rubric JSON. They never see prior scores or the
   author's assessment.
2. **Adjudicate, then aggregate.** The author-as-fixer **verifies every factual claim in every finding
   against the primary sources** (figures: check basis — period, denominator, scope). Findings that fail
   verification are struck, with evidence, into a `refuted` ledger. If a panelist's dimension scores rest
   materially on refuted findings, a **fresh-context critic (never the author)** re-derives that
   panelist's affected dimension scores from the surviving evidence. The pass verdict = the **minimum**
   `overall_score` across panelists **after this adjudication** (min is chosen for anti-leniency; the
   re-derivation step is what protects it from a hallucinating harsh judge — do not skip it).
3. **Stop?** DONE requires BOTH: adjudicated verdict `>= bar` **and** zero verified CRITICAL or MAJOR
   findings still open. (Score alone is not DONE.)
4. **Act on every VERIFIED finding.** Implement verified findings CRITICAL → NITPICK. Findings that are
   wrong go to `refuted`; findings that are valid but would harm the artifact, exceed the mandate, or
   belong to an owner go to `not_actioned` with rationale. Both ledgers are part of the pass log —
   *implementing an unverified finding is itself a defect.* (Field record of this kit: roughly a
   quarter to a third of critic recommendations did not survive verification.)
5. **Audit the fixes — and the refutations.** After each fix batch, an independent fresh-context critic
   receives the change list + the `refuted` ledger + the primary sources, audits **each change** for
   regressions (verdict per change: CONFIRMED / REGRESSION), and **spot-checks each refutation** against
   the sources (refuting a valid finding is the loop's main gaming vector). The author's fixes and
   strikes get the same scrutiny as the critics' claims — in this kit's own history, two
   author-introduced regressions were caught *only* by this step.
6. **Log the pass** → `_runs/critic_<target>_passN.json` (overall, per-dimension scores, verified /
   refuted / not_actioned ledgers, fix-audit result, delta vs previous). Git-ignored scratch — durable
   across a long loop.
7. **Re-evaluate** the *changed* artifact (back to step 1).

## Stop conditions (any one ends the loop)
- ✅ **Cleared the bar** — adjudicated verdict `>= bar` with zero open CRITICAL/MAJOR findings,
  **confirmed by an independent critic pass**.
- 🔁 **Max iterations** (default 5) — report best score + what remains.
- 📉 **Plateau** — two consecutive passes gain `< +1` point → stop (more looping is churn). Score deltas
  include panel-resampling noise, so near a plateau weigh the count of surviving findings, not the
  score alone.
- 🛑 **Would do harm** — the only remaining way to raise the score is a change that degrades the
  artifact (breaks functionality, correctness, or an external contract). **Stop below the bar and
  report an honest lower score; never make the harmful change.**
- ⚠ **Regression signal** — if a pass scores *below* the previous pass, do not push on: fix-audit the
  last change batch first.

## Calibration
The bar is a **parameter, not a constant**. The rubric's own bands call 90-100 "Exceptional — ready for
deployment", so the default bar is **≥ 90** (inclusive — the band edge itself qualifies). (This kit originally shipped with > 95; across 11 logged
runs under min-of-panel aggregation no artifact ever reached it — best honest score 89 — so every loop
terminated on a stop condition instead. A bar that can never bind measures nothing and invites the very
inflation the guardrails forbid.) Recalibrate from your repo's first few runs if your panel scores
systematically higher or lower.

## Measurement hygiene
The final reported score must describe the **shipped artifact**. Any change applied after the last
measured pass must be labelled **UNMEASURED** in the ledger; a CRITICAL or MAJOR post-measurement change
triggers one more confirming pass before the loop may report itself finished.

## ⚠ Guardrails — because this is self-scoring
The author, the judge, and the stop-button are the same agent, so "loop until I score *myself* past the bar"
is gameable — and the *judge* is fallible too. Non-negotiable, in both directions:
1. **Score honestly to the rubric, with evidence.** Never reverse-engineer a passing score just to
   terminate. An honest, defensible **88** beats a gamed **96**.
2. **Independent scoring (operationalized).** All scoring is done by **fresh-context critic
   sub-agents** (e.g. Claude Code's Agent tool, `general-purpose`): each prompt contains ONLY —
   (a) "read `Critic Agent 1.txt`; that is your rubric", (b) the target + which files to read + the
   assigned lens, (c) "return the JSON; do NOT modify files; do NOT inflate". They never see the
   author's self-assessment. The author only ever *fixes*, never *grades*.
3. **Independent verification (the judge is fallible).** Symmetrically: critic findings are *claims,
   not facts* until verified against primary sources, and the author's fixes are *changes, not
   improvements* until audited. Verify both. This is what makes "act on all recommendations" safe.
4. **Never degrade to score.** If clearing the bar needs a harmful change, stop below it and say so (🛑).
5. **Run the prompt's own anti-bias protocols** each pass — contrarian check + meta-critique (leniency / anchoring).

## This is an IN-SESSION long task — NOT VPS-detachable
The loop needs the model at *every* iteration to critique and revise, so it **cannot** run untethered on
a server like a pure-data job. It's a long *in-session* task. What CAN be detached: heavy *data*
sub-steps between passes (e.g. re-running an aggregation to refresh the evidence the critic scores
against) — see `../Detached-Long-Jobs-Runbook.md` *if the repo has it*. Keep the per-pass
`_runs/critic_*` log so a long loop's progress survives an interruption and can resume.

## Output each run
A short ledger: `pass # → adjudicated verdict → verified/refuted/not_actioned counts → top changes →
fix-audit result → delta`, ending in **cleared (with the independent check's score)** or **stopped — why**.
