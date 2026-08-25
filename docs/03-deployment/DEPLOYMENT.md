# Deployment — Resume

> How the project gets from `main` to production.

---

## Environments

| Env | URL | Branch | Auto-deploy |
|---|---|---|---|
| Dev | localhost | (local) | n/a |
| Staging | {{STAGING_URL}} | `main` | ✅ on push |
| Production | {{PROD_URL}} | tag `v*.*.*` | ✅ on tag |

## Infra

- **Compute:** {{COMPUTE_PROVIDER}} ({{COMPUTE_DETAILS}})
- **Database:** managed Postgres ({{POSTGRES_PROVIDER}})
- **Cache:** managed Redis ({{REDIS_PROVIDER}})
- **Object store:** {{OBJECT_STORE}}
- **CDN:** {{CDN_PROVIDER}}
- **DNS:** {{DNS_PROVIDER}}

## CI/CD pipeline

```
┌─────────┐    ┌──────────┐    ┌─────────┐    ┌──────────┐    ┌─────────┐
│  push   │───>│   lint   │───>│  test   │───>│  build   │───>│ deploy  │
│ main    │    │ + format │    │ + cov   │    │ image    │    │ staging │
└─────────┘    └──────────┘    └─────────┘    └──────────┘    └─────────┘

┌─────────┐    ┌──────────┐    ┌─────────┐    ┌──────────┐    ┌─────────┐
│   tag   │───>│   lint   │───>│  test   │───>│  build   │───>│ deploy  │
│ v*.*.*  │    │ + format │    │ + cov   │    │ image    │    │ prod    │
└─────────┘    └──────────┘    └─────────┘    └──────────┘    └─────────┘
```

See [.github/workflows/](../../.github/workflows/) for the actual workflow files.

## First-time prod setup

1. Provision infra (Terraform or click-ops — document either way).
2. Create database, run initial migrations.
3. Create object store buckets.
4. Configure DNS.
5. Configure secret manager with all required env vars (see `.env.example`).
6. Configure CI/CD with deploy credentials.
7. Push first tag.
8. Verify healthchecks green.
9. Run smoke tests against prod.
10. Update [RUNBOOK.md](RUNBOOK.md) with any prod-specific notes.

## Cost monitoring

- **Budget alert:** {{BUDGET_ALERT_THRESHOLD}}/month
- **Owner:** Chan Hoe
- **Review cadence:** monthly

## See also

- [RUNBOOK.md](RUNBOOK.md) — operational procedures
- [../../02_active/ARCHITECTURE.md](../../02_active/ARCHITECTURE.md) — what's being deployed
