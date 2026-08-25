# @resume/shared

> **Single source of domain truth.** Schemas, enums, state machine, types. Imported by every app.

---

## What lives here

| Subfolder | Owns |
|---|---|
| `src/schemas/` | Zod (TS) or Pydantic (Python) schemas for all entities |
| `src/state/` | State machine: status enums + transition rules |
| `src/types/` | Domain types (often inferred from schemas) |
| `src/constants/` | Shared constants (timeouts, limits, role names) |

## Rules

1. **No I/O.** Pure functions, types, schemas only. No DB calls, no HTTP, no logging.
2. **No app-specific knowledge.** If a value only one app needs, it belongs in that app.
3. **No circular dependencies.** Apps depend on `shared`; never the other way around.
4. **Public API via named exports.** Export only what apps should use. Use `index.ts` per subfolder for re-exports.

## Adding a new entity

1. Schema in `src/schemas/<entity>.ts` (Zod) or `src/schemas/<entity>.py` (Pydantic).
2. Inferred type in `src/types/<entity>.ts` (from schema, not duplicated).
3. Status enum (if applicable) in `src/state/<entity>State.ts`.
4. Re-export from `src/index.ts`.
5. Update tests in `tests/`.

## Example layout

```
packages/shared/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts                  # public re-exports
│   ├── schemas/
│   │   ├── case.ts               # CaseSchema, parseCase
│   │   └── user.ts
│   ├── state/
│   │   ├── caseState.ts          # CASE_STATUS, canTransition()
│   │   └── userRole.ts
│   ├── types/                    # inferred from schemas
│   │   └── index.ts
│   └── constants/
│       └── limits.ts
└── tests/
    └── state/caseState.test.ts
```
