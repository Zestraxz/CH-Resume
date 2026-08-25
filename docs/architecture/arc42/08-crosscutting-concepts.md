# 8. Crosscutting Concepts

| Concept | Implementation |
|---|---|
| Logging | Structured JSON via pino (TS) / structlog (Py); correlation ID per request |
| Metrics | OpenTelemetry; RED method for services, USE for resources |
| Tracing | OpenTelemetry; auto-instrumented HTTP/DB/queue |
| Error tracking | Sentry; sourcemaps uploaded in CI |
| Authn | JWT short-lived + refresh token (httpOnly cookie) |
| Authz | Middleware per route; deny by default |
| Validation | Zod (TS) / Pydantic (Py) at every boundary |
| Errors | Typed `AppError` hierarchy; HTTP status mapped at boundary |
| Config | Zod/Pydantic env validation at boot (fails build on bad env) |
| AI cost guardrails | `LLM_DAILY_BUDGET_USD` env cap; 429 on exceed |
