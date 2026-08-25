# AGENTS.md - @resume/api

> Sub-AGENTS.md for the API. Read AFTER the root [`../../AGENTS.md`](../../AGENTS.md).

---

## Scope

`apps/api/` is the backend service. Owns HTTP routes, services, repositories, background worker.

## Conventions

- All routes under `/api/v1/*`.
- Validation at boundary using schemas from `@resume/shared/schemas`.
- Errors are typed `AppError` subclasses (see `src/lib/errors.ts`).
- Logging via pino (`src/lib/logger.ts`); always include correlation ID.
- DB access ONLY via Prisma client (no raw SQL outside migrations).

## Don't import from

- `apps/web/*` (cross-app boundary - lint blocks).
- Other apps directly - use `packages/shared` for cross-app contracts.

## See also

- Backend-specific Cursor rules: `../../.cursor/rules/backend.mdc`
- Architecture: `../../02_active/ARCHITECTURE.md`
