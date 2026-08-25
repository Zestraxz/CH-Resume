# `.Critic/` — portable two-mode Critic kit (Radar + Microscope)

Drop this folder into any repo to get a disciplined critic that covers **both directions of doubt**:

- **Mode A — RADAR** (`Critic-Radar.md`): *what is this project missing?* A scheduled, zero-context
  discovery sweep — coverage map, layer check, claim audit, bounded external research — that finds
  the targets nobody points at, ranks them, and hands the top one to Mode B.
- **Mode B — MICROSCOPE** (`Critic-Agent-Loop.md`): *is THIS thing good enough?* The
  review-and-improve loop: independent critics score a named target against a fixed rubric, you
  **verify their findings against the primary sources**, act on the verified ones, **audit your own
  fixes for regressions**, iterating until the adjudicated score clears the bar (default **≥ 90**)
  with no CRITICAL/MAJOR findings open — or it stops honestly.

They compose: **the Radar finds the target; the Microscope perfects it.** The Radar runs weekly on a
schedule (so critique survives human forgetfulness) and includes ONE bounded Microscope scoring pass
on its top find; full improve-to-bar runs stay human-triggered via `/critic`.

> **v3** (unification): added the Radar mode after the field lesson that an on-demand critic silently
> stops running — three program-critical gaps (an unpriced tail risk, an unsearched combination
> space, an untouched execution layer worth more than all in-layer experiments combined) were found
> only when a human happened to ask. New hard boundary added for BOTH modes: **in domains with their
> own validation authority (e.g. a trading gauntlet), the critic proposes and verifies — it never
> modifies the validated system itself.** The domain's gauntlet is the improver.

> **v2.1** (self-critique round): the kit was scored by its own loop (3-lens panel verdict **58**) and
> fixed accordingly. The two CRITICAL findings — critic findings were treated as facts ("act on
> everything" with no verification duty), and author fixes were never audited for regressions — came
> straight from this kit's own field logs, where roughly a quarter to a third of critic recommendations
> did not survive verification and two author regressions were caught only by ad-hoc confirming passes.
> Both duties are now protocol. Also fixed: the >95 bar (never reached in 11 logged runs; now ≥90 +
> zero-open-CRITICAL/MAJOR, matching the rubric's own "90-100 = ready" band), min-vs-median ambiguity
> (now: minimum after adjudication), a FIDELITY ground-truth mode + panel lens assignment, figure
> basis-checking, the severity-taxonomy and score-floor inconsistencies, and cross-file drift
> (`Critic-Agent-Loop.md` is now canonical; this repo's `/critic` launcher actually exists).

## What's in here
| File | Role |
|---|---|
| `Critic-Radar.md` | **Mode A — canonical for the Radar rules**: the scheduled discovery sweep (coverage map · layer check · claim audit · bounded external research · rank + hand-off), its guardrails, and the per-project binding section. |
| `Critic Agent 1.txt` | The **evaluator** — a McKinsey-partner / principal-engineer rubric: 7 weighted dimensions, 20–100 score, JSON output. (One scored pass.) |
| `Critic-Agent-Loop.md` | **Mode B — canonical for the loop rules**: evaluate → verify findings → act on verified ones → audit fixes → re-score; stop conditions + guardrails in both directions. |
| `critic.command.md` | The **command body** the `/critic` slash command runs (operational summary; defers to the Loop file). |
| `radar-prompt.md` | The **zero-context prompt** the scheduler feeds to a fresh agent each week. Project-agnostic; reads the binding at runtime. |
| `install.sh` / `install.ps1` | The **porting installer** — drops the kit, launcher, docs stubs, and weekly workflow into any other repo. Idempotent. |
| `templates/` | Bootstrap files the installer copies: coverage map, refuted ledger, `/critic` launcher, `self-critic.yml`. |
| `README.md` | This file. |

## Use it in this repo
- **Radar**: runs automatically every **Monday** — see `docs/04-quality/critic/SOP-AUTONOMOUS-SELF-CRITIC.md`
  for the two backends (GitHub Actions `self-critic.yml`, and the local scheduled task) — or on
  demand: *"run the Critic Radar"*.
- **Microscope**: **`/critic <target> [bar]`** — e.g. `/critic the Cause system`, `/critic apps/web/entry.js 85`, or `/critic` (no args → reviews your current uncommitted changes).
- Or in plain English: *"Apply Critic Agent 1.txt and take action on all recommendations"* (the loop's trigger phrase — "take action" means *verify, then act*, per the loop).

The `/critic` command is wired via a one-line launcher at `.claude/commands/critic.md` that points here, so the procedure has a single source of truth in this folder.

## Drop into ANOTHER project — one command

From the target repo's root, run the installer that ships in this folder:

```bash
# from the OTHER repo's root
bash /path/to/CH-Critic/.Critic/install.sh .
```

```powershell
# Windows / PowerShell
& "C:\path\to\CH-Critic\.Critic\install.ps1" -Target .
```

It is **idempotent** (re-runnable) and does five things:
1. copies `.Critic/` into the target repo;
2. writes `.claude/commands/critic.md` (the `/critic` launcher);
3. seeds `docs/04-quality/critic/` with a **coverage map** + **refuted ledger** stub, pre-filled with
   the target repo's name and detected layers;
4. installs `.github/workflows/self-critic.yml` (weekly Radar; dormant until you add the auth secret);
5. appends `_runs/` to `.gitignore`.

Then do the **two things the installer cannot do for you**:
- **Edit the "Project binding" section** at the bottom of `Critic-Radar.md` — coverage-map/ledger/queue
  paths, the real layer list, any provability floor, and the domain's validation authority. The
  installer's guesses are placeholders; an unedited binding makes the Radar sweep the wrong surface.
- **Add the auth secret** so the schedule can actually fire — see the SOP §2, or run
  `install.sh --print-schedule` for the exact commands.

Pass `--no-workflow` to skip step 4 (e.g. non-GitHub remotes), or `--force` to overwrite an existing
`.Critic/`. Full flag list: `install.sh --help`.

> Prefer it in **every** project without installing per-repo? Copy `critic.md` to
> `~/.claude/commands/critic.md` — the `/critic` command then works anywhere, though the Radar still
> needs the per-repo binding + coverage map to have anything to sweep.

## The non-negotiable guardrails (why the score is trustworthy)
Because the author and the judge would otherwise be the same agent — and because the judge itself is
fallible — the loop guards in **both directions**:
- the **independent fresh-context critics do all scoring** — the author only *fixes*;
- **critic findings are claims, not facts** — every factual claim is verified against the primary
  sources before anyone acts on it; refuted findings go into a ledger, not into the artifact;
- **author fixes are changes, not improvements** — each fix batch is audited by an independent critic
  for regressions before the next pass, and the author's refutations are spot-checked too (striking a
  valid finding is the loop's main gaming vector);
- **never inflates a score to terminate** — an honest, defensible 88 beats a gamed 96;
- **never degrades the artifact just to clear the bar** — if reaching it needs a harmful,
  owner-dependent, or out-of-constraint change, it **stops and reports** instead;
- **never modifies a system that has its own validation authority** (both modes): on such targets
  (e.g. trading-strategy behavior gated by a backtest/noise/live gauntlet) the critic delivers
  *verified findings + proposed measurements* only — the gauntlet is the improver, not the critic.

## Note
This is an **in-session** loop (the model is needed every pass) — it is *not* runnable untethered on a
server like a pure-data job. (For long, no-model data jobs, see `../Detached-Long-Jobs-Runbook.md` if the
repo has it.) `Critic Agent 1.txt` keeps its name so the habitual *"Apply Critic Agent 1.txt"* prompt
still works.
