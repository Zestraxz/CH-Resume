# Privacy — Resume

> What data the project collects, why, and how it's protected.

---

## Data collected

| Category | Examples | Why | Retention |
|---|---|---|---|
| User identity | Email, hashed password | Authentication | Lifetime of account |
| Usage | API requests, latency, errors | Operational reliability | 30 days (logs), 90 days (metrics) |
| Content | User-submitted data per feature | Core functionality | Per feature; see retention table below |
| Audit | State-change events | Compliance, debugging | 1 year (configurable) |

## Personal data handling

- **At rest:** encrypted at column level for sensitive fields (PII, secrets)
- **In transit:** TLS 1.2+ for all external communication
- **Backups:** encrypted; same retention as live data
- **Access:** least-privilege; access logs in audit table

## Third-party services

| Provider | Data shared | Purpose |
|---|---|---|
| {{AI_PROVIDER}} | User prompts (if AI features enabled) | LLM inference |
| {{TELEMETRY_PROVIDER}} | Anonymized error reports | Crash diagnostics |
| {{ANALYTICS_PROVIDER}} | Anonymized usage events | Product analytics |

Users can opt out of telemetry and analytics via `FEATURE_TELEMETRY_ENABLED=false`.

## Data subject rights

Per GDPR / equivalent regulations:

- **Access** — request a copy of all data held about you (within 30 days)
- **Rectification** — correct inaccurate data
- **Erasure** — delete account and associated data (within 30 days; some audit records retained per legal obligation)
- **Portability** — export your data in a machine-readable format
- **Restriction** — limit processing pending dispute resolution

Contact the maintainer (see [CODEOWNERS](../../CODEOWNERS)) to exercise rights.

## Children's data

The project is not intended for users under 16. We do not knowingly collect data from minors.

## Changes to this policy

Material changes are announced via [../../CHANGELOG.md](../../CHANGELOG.md) and tagged in the repo.
