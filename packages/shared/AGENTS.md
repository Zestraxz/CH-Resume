# AGENTS.md - @resume/shared

> Sub-AGENTS.md for the shared package. Read AFTER the root [`../../AGENTS.md`](../../AGENTS.md).

---

## Scope of this package

`packages/shared/` is the **single source of domain truth** for the monorepo. It owns:

- Zod schemas for every cross-process entity (`src/schemas/`)
- Status enums + state-machine transitions (`src/state/`)
- Inferred types (`src/types/`)
- Constants (limits, role names, timeouts) (`src/constants/`)
- Env validation schemas (`src/env.ts`)

## Hard rules

1. **No I/O.** Pure functions, types, schemas. No DB calls, no HTTP, no logging.
2. **No app-specific knowledge.** If only one app needs a value, it belongs in that app.
3. **No upward deps.** `packages/shared` cannot import from `apps/*` or `features/*`. Lint enforces this.
4. **Public API via named exports.** Export only what apps should use. Use `index.ts` per subfolder for re-exports.
5. **Backward compat by default.** Schema changes that break consumers require a major version bump + migration note in CHANGELOG.

## Adding a new entity

1. Schema in `src/schemas/<entity>.ts`.
2. Inferred type from schema (don't hand-write).
3. Status enum (if applicable) in `src/state/<entity>State.ts`.
4. Re-export from `src/index.ts`.
5. Add test in `tests/`.
6. Bump version in `package.json` if breaking.
