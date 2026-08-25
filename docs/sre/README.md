# SRE Documentation

> Site Reliability Engineering for Resume.

---

## Contents

- [error-budget-policy.md](error-budget-policy.md) - what happens when SLO budget is exhausted
- SLO definitions: [`../../slo/*.yaml`](../../slo/) (OpenSLO format)
- Burn-rate alerts: [`../../slo/alerts.yaml`](../../slo/alerts.yaml)
- Runbooks: [`../03-deployment/RUNBOOK.md`](../03-deployment/RUNBOOK.md)

## Current SLOs

| SLO | Target | Window | Source |
|---|---|---|---|
| API availability | 99.5% | 30d rolling | `slo/api-availability.yaml` |
| API p95 latency | < 200ms | 30d rolling | `slo/api-availability.yaml` |

## DORA metrics (we measure)

| Metric | Source | Current |
|---|---|---|
| Deployment frequency | `.github/workflows/dora-metrics.yml` | TBD |
| Lead time for changes | Same | TBD |
| Change failure rate | Same | TBD |
| Failed deployment recovery time | Same | TBD |

## References

- [Google SRE Workbook - Implementing SLOs](https://sre.google/workbook/implementing-slos/)
- [Google SRE Workbook - Alerting on SLOs](https://sre.google/workbook/alerting-on-slos/)
- [OpenSLO spec](https://openslo.com/)
- [DORA metrics guide](https://dora.dev/guides/dora-metrics/)
