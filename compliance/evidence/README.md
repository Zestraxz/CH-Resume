# Evidence

> Per-release artifacts for auditor review.

---

## Layout

```
evidence/
  v0.1.0-2026-MM-DD/
    ci-results.sarif
    sbom-cyclonedx.json
    sbom-spdx.json
    slsa-provenance.intoto.jsonl
    cosign-signatures.txt
    dependency-audit.json
  v0.2.0-2026-MM-DD/
    ...
```

Auto-populated by `.github/workflows/release.yml` on every `v*.*.*` tag push.

## Retention

Keep for the duration of any active compliance commitment. For SOC 2 Type 2, retain at least 12 months.

## Don't delete

Even after auditor review. Future audits may cross-reference prior evidence.
