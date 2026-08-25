# Live Operation Steps — Resume

> Manual fallback when `run.ps1` / `run.sh` won't suffice (CI debugging, custom env, partial setup).

---

## 1. Prerequisites

| Tool | Minimum | Verify |
|---|---|---|
| Node | 20.18.0 | `node -v` |
| pnpm | 9.0.0 | `pnpm -v` |
| Python | 3.11 | `python --version` |
| Docker | 24.x | `docker -v` |
| git | 2.40 | `git --version` |

## 2. First-time setup

```bash
# Clone
git clone <repo-url>
cd resume

# Environment
cp .env.example .env
# Edit .env — fill in real secrets

# Dependencies (Node)
pnpm install

# Dependencies (Python)
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\Activate.ps1 on Windows
pip install -e ".[dev]"
```

## 3. Bring up services

```bash
# Dev (minimal: postgres + redis)
docker compose up -d

# Verify health
docker compose ps
docker compose logs --tail=50

# Stop
docker compose down

# Reset (destroys data)
docker compose down -v
```

## 4. Database

```bash
# Run migrations (Node)
pnpm db:migrate

# Run migrations (Python / Alembic)
alembic upgrade head

# Seed dev data
pnpm db:seed
```

## 5. Start app processes (dev)

```bash
# All apps in parallel watch mode
pnpm dev

# Specific app
pnpm --filter @resume/api dev
pnpm --filter @resume/web dev

# Python
python -m resume
```

## 6. Healthcheck URLs

| Service | URL |
|---|---|
| Frontend | http://localhost:3000 |
| API | http://localhost:8000 |
| API docs | http://localhost:8000/docs |
| API health | http://localhost:8000/health |

## 7. Common fixes

| Symptom | Fix |
|---|---|
| Port already in use | `docker compose down` or kill the process bound to the port |
| Postgres won't start | Check `docker compose logs postgres`; usually permission on volume — `docker compose down -v && docker compose up -d` |
| `pnpm install` hangs | Delete `node_modules` + `pnpm-lock.yaml`, retry |
| TS errors after rebase | `pnpm clean && pnpm install && pnpm typecheck` |
| Python ModuleNotFound | Ensure venv activated; re-run `pip install -e ".[dev]"` |

## 8. Tear down completely

```bash
docker compose down -v       # services + volumes
rm -rf node_modules dist .pnpm-store
rm -rf .venv __pycache__ *.egg-info
```
