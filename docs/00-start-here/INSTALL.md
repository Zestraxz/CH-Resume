# Install — Resume

> Full install when [QUICKSTART.md](QUICKSTART.md) isn't enough.

---

## Prerequisites

| Tool | Min | Install |
|---|---|---|
| Node | 20.18.0 | https://nodejs.org/ |
| pnpm | 9.0.0 | `npm install -g pnpm` |
| Python | 3.11 | https://python.org (if project uses Python) |
| Docker Desktop | 24.x | https://docker.com/products/docker-desktop |
| git | 2.40 | https://git-scm.com |

Pinned versions:
- Node: see `.nvmrc`
- pnpm: see `packageManager` in `package.json`
- Python: see `requires-python` in `pyproject.toml`

## Cloning

```bash
git clone <repo-url>
cd resume
```

## Environment

```bash
cp .env.example .env
# Edit .env — fill in real values (especially JWT_SECRET, POSTGRES_PASSWORD)
```

**Required variables** (will fail without them in prod):
- `DATABASE_URL`
- `JWT_SECRET`
- `CORS_ORIGINS`

Optional (only if app uses these providers):
- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`

## Dependencies

```bash
# Node
pnpm install

# Python (if applicable)
python -m venv .venv
source .venv/bin/activate              # Unix
.venv\Scripts\Activate.ps1              # Windows
pip install -e ".[dev]"
```

## Services

```bash
# Bring up postgres + redis
docker compose up -d

# Verify
docker compose ps
docker compose logs --tail=50
```

## Database migrations

```bash
# Node (Prisma)
pnpm db:migrate

# Python (Alembic)
alembic upgrade head
```

## Start app processes

```bash
# All apps (parallel watch mode)
pnpm dev

# Specific app
pnpm --filter @resume/api dev
pnpm --filter @resume/web dev

# Python CLI
python -m resume
```

## Verify

| Service | URL | Expected |
|---|---|---|
| Frontend | http://localhost:3000 | App home page |
| API | http://localhost:8000 | JSON response |
| API health | http://localhost:8000/health | `{"status":"ok"}` |
| API docs | http://localhost:8000/docs | OpenAPI UI |

## Troubleshooting

See [../03-deployment/RUNBOOK.md](../03-deployment/RUNBOOK.md) for common service failures.
