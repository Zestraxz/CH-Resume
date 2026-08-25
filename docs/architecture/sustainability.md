# Sustainability

> AWS Well-Architected 6th pillar (added Dec 2021).

## Carbon-aware practices

| Practice | Status | Note |
|---|---|---|
| Region selection by carbon intensity | {{TODO}} | Use [electricitymaps.com](https://app.electricitymaps.com/) when picking region |
| Right-sized instances | {{TODO}} | Avoid over-provisioning; autoscale on real demand |
| Cache aggressively | {{TODO}} | CDN + Redis reduce backend energy |
| Compress assets | {{TODO}} | gzip / brotli on all text responses |
| Cold tier for archival data | {{TODO}} | S3 Glacier / equivalent for `03_history` analog at infra level |
| Schedule batch jobs at low-demand hours | {{TODO}} | Often coincides with cleaner grid |

## Targets

- Total runtime carbon < {{TODO}} kg CO2e / month
- Bundle size < 200KB gzipped (less data = less transit energy)

## References

- [AWS Sustainability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/sustainability-pillar/sustainability-pillar.html)
- [Green Software Foundation patterns](https://patterns.greensoftware.foundation/)
- [Cloud Carbon Footprint](https://www.cloudcarbonfootprint.org/)
