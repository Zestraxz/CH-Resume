# Quickstart — Resume

> Running in 5 minutes. Assumes Node 20+, pnpm 9+, Docker Desktop installed and running.

---

## TL;DR

```bash
git clone <repo-url> && cd resume
cp .env.example .env
pnpm install
docker compose up -d
pnpm dev
```

Then open http://localhost:3000.

## Or — one-click (Windows)

Double-click `START_HERE.cmd`.

## Verify it's working

```bash
curl http://localhost:8000/health     # → {"status":"ok"}
```

Or open http://localhost:8000/docs for the API docs.

## What to do next

- Read [../../STATUS.md](../../STATUS.md) to see what's in flight
- Read [../../CLAUDE.md](../../CLAUDE.md) for code conventions
- Pick a task from [../../02_active/ROADMAP.md](../../02_active/ROADMAP.md)
