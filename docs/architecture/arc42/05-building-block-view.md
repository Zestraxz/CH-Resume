# 5. Building Block View

See [`../workspace.dsl`](../workspace.dsl) Container view.

## Level 1 (containers)

- `apps/web` - frontend SPA
- `apps/api` - REST API
- `apps/api` worker - async job processor (same image, different entrypoint)
- Postgres - transactional store
- Redis - cache + queue
- Object store - binary blobs

## Level 2 (key components inside API)

- `routes/` - HTTP boundary; Zod-validated
- `services/` - business logic
- `repositories/` - data access (Prisma/SQLAlchemy)
- `lib/` - cross-cutting utilities (logger, api client, errors)
