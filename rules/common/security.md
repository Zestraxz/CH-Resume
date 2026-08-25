# Common Security Rules

> Applies to all languages.

---

## Input

- **Validate at the boundary.** Zod / Pydantic at every HTTP route, queue handler, file ingest.
- **Never trust client-supplied IDs.** Re-look-up server-side and check authorization.
- **Sanitize before storage AND before output.** Defense in depth.

## Secrets

- **Never in source code.** Use `.env` (dev) + secret manager (prod).
- **Never in logs.** Structured logging filters; review before adding new log lines.
- **Never in test fixtures.** Use clearly-fake values (`"test-token-xxxxxx"`).
- **Never in client bundles.** Anything with `VITE_` / `NEXT_PUBLIC_` is public — assume it's on a billboard.

## Auth

- Short-lived JWT (≤ 15 min) + refresh token (httpOnly, secure, sameSite=lax).
- Refresh rotation: each refresh issues a new refresh token; old one becomes invalid.
- Logout invalidates server-side (don't trust client-only logout).
- Failed login: rate-limit + log; don't reveal whether email exists.

## Authorization

- Check authorization on **every** endpoint, not just login.
- Use middleware / decorator pattern so it's hard to forget.
- Deny by default; allow by explicit role.

## Database

- Parameterized queries only. Never string-concat user input into SQL.
- Migrations forward-only (don't rewrite shipped migrations).
- Backups encrypted, tested via restore drill.

## Dependencies

- `pnpm audit` / `pip-audit` in CI; block on `high` and `critical`.
- Dependabot weekly updates; review before merging.
- Lock files committed; reproducible installs.

## Headers (web)

| Header | Value |
|---|---|
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` |
| `Content-Security-Policy` | Tight; no `unsafe-inline` for scripts |
| `X-Content-Type-Options` | `nosniff` |
| `X-Frame-Options` | `DENY` (or `SAMEORIGIN`) |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |

## Audit log

- Every state-change has an audit row (who, what, when, where).
- Append-only (no UPDATE / DELETE on audit table).
- Retention per [docs/02-governance/PRIVACY.md](../../docs/02-governance/PRIVACY.md).

## Anti-patterns

- ❌ `eval` / `exec` on user input
- ❌ `INSERT INTO ... VALUES ('${userInput}')`
- ❌ `console.log(password)` even temporarily
- ❌ Disabling TLS verification "for now"
- ❌ Wildcards in `CORS_ORIGINS` in production
- ❌ Long-lived API tokens checked into env files
