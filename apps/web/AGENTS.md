# AGENTS.md - @resume/web

> Sub-AGENTS.md for the frontend. Read AFTER the root [`../../AGENTS.md`](../../AGENTS.md).

---

## Scope

`apps/web/` is the frontend SPA. Owns pages, components, stores, API client wrapper.

## Conventions

- Pages in `src/pages/` (route-scoped).
- Components in `src/components/` (reusable, stateless).
- Stores in `src/stores/` (one per domain).
- All API calls via `src/lib/api.ts` - never bare `fetch` in components.
- Tailwind for styling; design tokens in `tailwind.config.js`.

## Performance budgets

- LCP < 2.5s
- INP < 200ms
- CLS < 0.1
- JS bundle < 200KB gzipped (enforced by `size-limit`)

## Don't import from

- `apps/api/*` - cross-app boundary.
- Other features' internals - keep slices independent.

## See also

- Frontend-specific Cursor rules: `../../.cursor/rules/frontend.mdc`
- Architecture: `../../02_active/ARCHITECTURE.md`
