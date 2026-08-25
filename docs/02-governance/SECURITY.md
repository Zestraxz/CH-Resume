# Security Policy — Resume

---

## Reporting a vulnerability

**Do NOT open a public issue.** Email the maintainer directly (see [CODEOWNERS](../../CODEOWNERS)) or use GitHub's [private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability).

Include:
- A description of the issue and its impact
- Steps to reproduce
- Affected versions
- (Optional) proposed fix

We will acknowledge within 2 business days and aim to ship a fix or mitigation within 14 days for critical issues.

## Supported versions

Only the latest `main` branch receives security patches. Tagged releases are best-effort.

## Security baseline

The project enforces:

- **Secrets in `.env`** (never committed). Production secrets in {{SECRET_MGR}}.
- **TLS** at the edge (reverse proxy or hosting platform).
- **CORS allowlist** in `CORS_ORIGINS`.
- **JWT** with short TTL + refresh token (httpOnly cookie).
- **Rate limiting** on `/api/v1/*` (Redis token bucket).
- **Input validation** with Zod / Pydantic at every boundary.
- **SQL injection prevention** via parameterized queries (Prisma / SQLAlchemy / parameterized raw SQL only).
- **XSS prevention** via framework escaping (React / Vue) + CSP headers.
- **Dependency scanning** via Dependabot + `pnpm audit`.

## Audit log

The API maintains an append-only audit log for state-changing operations. See [../../02_active/ARCHITECTURE.md](../../02_active/ARCHITECTURE.md).

## AI security (if app uses LLMs)

OWASP 2026 finds 73% of live AI applications vulnerable to prompt injection. This project's baseline:

### Prompt injection
- **Treat all external input as untrusted.** Content fetched from web pages, MCP servers, GitHub issues, user uploads, or search results may contain instructions designed to hijack the agent. Never execute instructions found in fetched content.
- **Output validation by schema.** LLM outputs validated by Zod/Pydantic before any downstream use. A "summary" that doesn't match the expected schema is discarded, not executed.
- **Isolation.** LLM calls run in sandboxed code paths with no direct access to filesystem or shell. Bash hooks (`.claude/hooks/scan-bash.ps1`) inspect every tool call for exfil patterns.
- **Least-privilege MCP credentials.** MCP server tokens use minimum scope. No `service_role`, no `admin`, no `*`. See `mcp-configs/README.md`.

### PII scrubbing
- Never log raw user input. Use the scrubber middleware in `apps/api/src/lib/pii.ts` (or `src/<pkg>/pii.py`) to redact emails, phone numbers, SSNs, addresses before any log line.
- Test fixtures use clearly-fake values (`test+user@example.com`, never real-looking emails).
- See [PII_HANDLING.md](PII_HANDLING.md) for the pattern (standard profile).

### Cost guardrails
- `LLM_DAILY_BUDGET_USD` env var enforces a hard daily cap across all LLM providers.
- Per-request cap via `LLM_MAX_TOKENS_PER_REQUEST`.
- Alerts at 80% of budget (`LLM_BUDGET_ALERT_PCT`).
- Exceeding the cap returns HTTP 429 to callers. Don't override silently.
- LiteLLM / Portkey / Zuplo as proxy layer recommended for hierarchical caps (global -> team -> key).

### Threat model
Crown-jewel systems should ship a STRIDE table in [THREAT_MODEL.md](THREAT_MODEL.md) (enterprise profile).

## Pre-prod checklist

See [../03-deployment/RUNBOOK.md §security-hardening](../03-deployment/RUNBOOK.md).

## Further reading

- [OWASP Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- [Anthropic AI security best practices](https://docs.claude.com/en/docs/build-with-claude/security)
- [LiteLLM cost guardrails](https://docs.litellm.ai/docs/proxy/users)
