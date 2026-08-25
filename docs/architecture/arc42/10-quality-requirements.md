# 10. Quality Requirements

## Quality tree

- Performance
  - API p95 < 200ms
  - API p99 < 500ms
  - Frontend LCP < 2.5s
  - Frontend INP < 200ms
  - Worker p95 < 5s
- Reliability
  - SLO: 99.5% (uptime)
  - Error budget: 0.5% / 30d
- Security
  - OSSF Scorecard >= 8/10
  - Dependency scan: zero high/critical
- Maintainability
  - Test coverage >= 70% new code
  - CI gate < 10 min

## Quality scenarios

{{TODO: per arc42 method - specific scenarios mapping to quality attributes}}
