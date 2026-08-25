# Operator Guide - Resume

> For the person who **runs** the system day-to-day (not the person who built it).
> If you're the builder, see [README.md](../../README.md) and [`02_active/ARCHITECTURE.md`](../../02_active/ARCHITECTURE.md).
> If something is broken, see [`../03-deployment/RUNBOOK.md`](../03-deployment/RUNBOOK.md).

---

## What this system does

TODO: paragraph describing Resume

## Daily operation

| What | Command | When |
|---|---|---|
| Bring everything up | `.\START_HERE.cmd` (Windows) / `./01_setup/run.sh` (Unix) | Each morning / after reboot |
| Open docs + URLs | `.\OPEN_ARTIFACTS.cmd` | When you need to look something up |
| Check health | `.\scripts\02-verify\verify-local.ps1` | Periodically; before deploying |
| Stop everything | `docker compose down` | End of day |

## Key URLs (when running locally)

| Service | URL | Healthy looks like |
|---|---|---|
| Frontend | http://localhost:3000 | App home page renders |
| API | http://localhost:8000 | JSON `{"status":"ok"}` at `/health` |
| API docs | http://localhost:8000/docs | OpenAPI/Swagger UI |

## Periodic tasks

| Task | Frequency | Command |
|---|---|---|
| Pull latest | Daily | `git pull --rebase` |
| Update deps | Weekly | review Renovate / Dependabot PRs |
| Backup DB (prod only) | Daily auto | see `04_tools/backup/` |
| Restore drill (prod only) | Quarterly | see `docs/03-deployment/RUNBOOK.md` |
| Rotate secrets | Quarterly | see `.env.example` + secret manager |

## Common operator scenarios

### "Service won't start"

1. `.\scripts\02-verify\verify-local.ps1` — check what's failing
2. `docker compose logs --tail=200 <service>` — read recent errors
3. `docker compose restart <service>` — try a restart
4. If still broken: see `docs/03-deployment/RUNBOOK.md` per-service playbooks

### "I need to deploy"

1. Read `docs/03-deployment/DEPLOYMENT.md` first
2. Confirm CI is green on the commit you want to ship
3. Tag the release: `git tag v0.X.Y && git push --tags`
4. CI handles the rest (see deploy workflow)

### "I need to add an env var"

1. Add it to `.env.example` first (variable name + placeholder value)
2. Add validation to env schema (`packages/shared/src/env.ts` or `src/<pkg>/config.py`)
3. Update production secret manager
4. Document in this file under "Required env vars"

### "I broke something and want to roll back"

1. `git log --oneline -10` — find the last good commit
2. For code: revert the bad commit. Don't reset main.
3. For prod: re-deploy the previous tag — see RUNBOOK.

## Required env vars (production)

The system refuses to boot without these (env validation fails fast).

| Var | What it's for | Where to set in prod |
|---|---|---|
| `DATABASE_URL` | Postgres connection | Secret manager |
| `REDIS_URL` | Cache + queue | Secret manager |
| `JWT_SECRET` | Auth | Secret manager (rotate quarterly) |
| `SESSION_SECRET` | Sessions | Secret manager (rotate quarterly) |
| `CORS_ORIGINS` | Allowed origins | Env var, no comma in domain |

For the full list, see `.env.example`.

## Escalation

- Service down: see `docs/03-deployment/RUNBOOK.md`
- Security incident: see `docs/02-governance/SECURITY.md`
- Data subject request (GDPR): see `docs/02-governance/PRIVACY.md`
- Unknown / panic: contact the maintainer (see `CODEOWNERS`)

## DO NOT

- Run destructive ops (DROP, DELETE without WHERE, `git push --force` to `main`) without confirmation
- Push commits without running `pnpm precommit` first (or equivalent)
- Disable env validation to "make it boot" — the env is wrong; fix it
- Commit secrets, `.env`, or generated files
