# 3. System Scope and Context

See [`../workspace.dsl`](../workspace.dsl) for the C4 model.

## Business context (who interacts with the system)

| Communication partner | Inputs | Outputs |
|---|---|---|
| End user | HTTPS requests | HTML, JSON |
| OTel collector | (none) | OTLP telemetry |
| Sentry | (none) | Error events |
| LLM providers | API calls | Model responses |

## Technical context (protocols, channels)

- HTTPS (TLS 1.2+) for all external traffic.
- Postgres protocol on private network only.
- Redis protocol on private network only.
- OTLP over HTTPS for telemetry.
