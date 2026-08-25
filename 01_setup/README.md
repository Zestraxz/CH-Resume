# 01_setup — Bootstrap & Operations Playbook

> Run me first. Mutable across releases.

---

## Contents

| File | Role |
|---|---|
| `run.ps1` | Windows bootstrap (PowerShell) — orchestrates the full setup |
| `run.sh` | Unix bootstrap (Bash) — orchestrates the full setup |
| `LIVE_OPERATION_STEPS.md` | Step-by-step manual fallback |

## How this differs from `scripts/`

- **`01_setup/`** — one-shot **manual setup playbook**. Runs once per machine. Orchestrates prerequisites + deps + delegates to `scripts/00-start/` for service bring-up.
- **`scripts/`** — **lifecycle automation** invoked many times during normal dev (start, verify, migrate, sync). Each subfolder is one phase.

Think of it as: `01_setup` is the install wizard; `scripts/` is the daily toolbox.

## What `run.{ps1,sh}` does

1. **Verify prerequisites.** Node ≥ 20.18.0, pnpm ≥ 9 (or Python ≥ 3.11), Docker Desktop, git.
2. **Create `.env`** from `.env.example` if absent (prints warning to fill in real values).
3. **Install dependencies.** `pnpm install` and/or `pip install -e ".[dev]"`.
4. **Bring up services.** `docker compose up -d`.
5. **Wait for healthchecks.** Polls each service until ready or timeout.
6. **Optional: open browser.** Frontend and API docs.
7. **Print readiness report.** What ran, what's at which URL, what to do next.

## When to re-run

- New clone
- After `git pull` with `package.json` / `pyproject.toml` changes
- After environment variable changes
- After Docker compose changes

Idempotent — safe to re-run any time.

## Manual fallback

See [LIVE_OPERATION_STEPS.md](LIVE_OPERATION_STEPS.md) if the script fails or you want full control.
