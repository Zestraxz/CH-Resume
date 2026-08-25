# Critic-Radar — the discovery mode (Mode A)

> **Canonical for the Radar rules.** The kit has two modes: **Radar** (this file — find what the
> project is missing) and **Microscope** (`Critic-Agent-Loop.md` — improve a named target to the
> bar). The README explains how they compose. The Radar was born in the CH-AutoTrade program
> (2026-08) after its operator observed that critical gaps — an unpriced tail risk, an unsearched
> combination space, an unmeasured execution drag worth more than every signal experiment combined —
> surfaced only when a human happened to ask. A critic that must be pointed at a target cannot find
> the targets nobody points at. The Radar exists to hunt them, on a schedule, with zero memory of
> who forgot what.

## What the Radar does (one run)

**Inputs (all in-repo — the Radar must work with zero session context):**
- the **coverage map** (`docs/.../COVERAGE.md` or project equivalent): covered/untried matrix,
  ranked backlog, prior reports — the Radar's memory;
- the **decisions/refuted ledger**: what failed, what's law, with evidence — the Radar's discipline;
- the current **roadmap/queue** doc, plus any domain-facts docs the binding section names.

**The five duties, in order:**

1. **Coverage sweep.** Walk the coverage map row by row. For every row not ✅: is there a
   zero/low-cost measurement that would settle it? If yes, queue it as a finding — do not wait to
   be asked. Rows completed since last run get their status updated (evidence link required).
2. **Layer check.** Name the project's layers (binding section). For each layer ask: what has
   NEVER been tried here? Hard-won rules from one layer must not veto another — this is the
   Radar's sharpest tool, because mature projects over-generalize their laws (field result: an
   entire untouched layer, worth more than 140 in-layer experiments, hid behind misapplied laws).
3. **Claim audit.** For every "X is closed / refuted / impossible / done" claim in the docs:
   closed for **what class of change**? One-at-a-time ≠ combinatorial; edge ≠ insurance; two
   tested points ≠ a frontier. Over-broad claims become findings.
4. **External check** (bounded: **max 8 web searches** per run). What are the best practitioners
   and current open-source projects in this domain doing that this project is not? Report ONLY
   findings that map to a concrete applicable action. Generic advice is banned output.
5. **Rank and bound.** Rank all findings by expected-value / cost. For each of the top findings,
   name: the mechanism (one line), the nearest failed/refuted class in the ledger and the
   distinction (mandatory — a Radar that re-proposes dead ideas is worse than none), and the
   **cheapest first measurement** that could kill it.

**Then hand off to Mode B (bounded):** run ONE Microscope scoring pass — panel of 2 fresh-context
critics + verification per `Critic-Agent-Loop.md` steps 1–2 ONLY, no improve-iterations — on the
single top-ranked target, so the report leads with at least one **scored, source-verified** item,
not just proposals. (Full improve-to-bar runs stay human-triggered via `/critic`.)

## Delivery

Append a dated report (≤60 lines) to the coverage map's reports section and update its rows;
commit on a branch `self-critic/YYYY-MM-DD` and push (fallback if push fails: print the full
report). Always end with a 5-line executive summary: best new opportunity · most dangerous
gap/over-broad claim · anything in the current queue now obsolete.

## The non-negotiable guardrails

- **The Radar proposes; it never modifies the system it critiques.** In domains with their own
  validation authority (a trading gauntlet, a clinical protocol, a release process), findings stop
  at *verified finding + proposed measurement*. The domain's gauntlet is the improver — a critic
  that "improves" a validated system directly is the failure mode, not the feature.
- **Ledger first.** No proposal from a class the decisions ledger marks failed, unless the
  proposal explicitly defeats the ledger entry's evidence. Nearest-failed-class naming is
  mandatory on every finding.
- **Provability floors are findings-filters.** If the project has a measured resolution floor
  (e.g., effects below X are statistically unprovable), sub-floor proposals in that layer are
  auto-rejected — prefer layers where the floor does not apply.
- **Rejected findings are context, not garbage.** Human triage rejections (with reasons) stay in
  the reports section; next run's Radar reads them and must not re-raise without new evidence.
- **Bounded or nothing.** Search caps, report-length caps, one Mode-B pass. An unbounded critic
  becomes the cost center it was meant to catch.

## Scheduling (what makes it autonomous)

Run weekly on a cron with an isolated repo checkout and zero prior context — creation recipe and
project-agnostic prompt template: **`docs/04-quality/critic/SOP-AUTONOMOUS-SELF-CRITIC.md` §2**.
Two supported backends, both billed to an existing Claude subscription (no API credits):
**GitHub Actions** (`.github/workflows/self-critic.yml`, travels with the repo) and a **local
scheduled task** (`~/.claude/scheduled-tasks/`). Manual invocation works identically: *"run the
Critic Radar"* in any session with the repo open.

## Project binding — Zestraxz/CH-Project-Architecture (edit this section when porting)

- Coverage map: `docs/04-quality/critic/COVERAGE.md` (§B map, §C backlog, §E reports)
- Decisions ledger: `docs/04-quality/critic/REFUTED-LEDGER.md` (the laws: L-*)
- Queue/roadmap: `02_active/ROADMAP.md` (Now/Next/Later + phases); status in `STATUS.md`
- Layers: `template` · `initializer` · `verification` · `ci-quality` · `docs` · `critic-kit` ·
  `scheduling` · `portability` · `ops` (definitions: `COVERAGE.md` §D)
- Provability floor: this repo has **no runtime, no benchmark suite, and no telemetry**. Only two
  instruments exist: `01_setup/verify-template.ps1` / `.sh` (binary pass/fail assertions per
  `-Profile × -Stack`), and Critic Agent panel scores, where **deltas < 3 points are within
  panel-resampling noise** and may not on their own justify a proposal. A finding whose only
  available evidence is subjective quality must be labelled unprovable rather than scored.
  (Initial estimate, not yet measured on this repo; recalibrate from the first 3 runs per
  *Calibration* in `Critic-Agent-Loop.md`.)
- Domain validation authority: **the Microscope loop itself** (`/critic`) is the validation authority
  for `.Critic/**` — the protocol files. The Radar may propose changes to the protocol but **must not
  edit `.Critic/**` directly**; such findings are handed to a `/critic .Critic/<file>` run, which
  scores them through an independent panel. Rationale: this repo's critic critiques its own protocol,
  so an unmediated self-edit is exactly the author-is-the-judge failure the kit exists to prevent.
- Second authority — **`template/**` is the product, not the repo.** A rule proven about this
  meta-repo does not transfer to the scaffold it emits, and vice versa. Changes to `template/**` are
  gated by `01_setup/verify-template.ps1` (per `AGENTS.md` §3.2, mandatory before push); the Radar
  proposes there but must not treat an unrun smoke test as a passing one.
- Repo scaffolding outside `.Critic/**` and `template/**` has no separate authority. **Note:** this
  repo has no `.github/workflows/ci.yml` — as of 2026-08-08 the only workflow is `self-critic.yml`
  itself, so nothing mechanically gates the `AGENTS.md` §3 PowerShell rules (COVERAGE §B6/C2). Do not
  cite CI as a gate here until one exists.
