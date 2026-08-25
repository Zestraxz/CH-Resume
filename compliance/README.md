# compliance/

> Auditor-ready evidence layout for SOC 2 / ISO 27001 / GDPR.

---

## Subfolders

| Folder | Contents |
|---|---|
| `access-reviews/` | Quarterly access reviews (who has access to what, signed by manager) |
| `evidence/` | CI-generated SARIF, SBOM exports, scan results - one timestamped per release |
| `data-flow-diagram.md` | GDPR Article 30 record - what personal data flows where |

## Audit prep checklist (SOC 2 Type 2)

- [ ] CODEOWNERS covers every path
- [ ] Branch protection on `main` (no force-push, signed commits, required reviews)
- [ ] Audit log retained 12+ months (GitHub default is 90 days - stream to Splunk/Datadog)
- [ ] Vulnerability remediation SLA documented + adhered to
- [ ] Quarterly access reviews completed + filed in `access-reviews/`
- [ ] Last release has CycloneDX + SPDX SBOMs attached
- [ ] Last release has SLSA L3 provenance attestation
- [ ] All container images signed via Cosign
- [ ] Threat model exists for crown-jewel systems (see `../docs/02-governance/THREAT_MODEL.md`)

## What auditors actually want

(From real audits in 2025-2026:)

1. **Evidence is immutable + timestamped.** They don't want "we usually do X" - they want logs of you doing X.
2. **Trail of who-reviewed-what-when.** GitHub PR + CODEOWNERS approval = trail.
3. **Segregation of duties.** Same person can't propose AND approve. CODEOWNERS prevents.
4. **Vulnerability tracking.** OSSF Scorecard + Dependabot/Renovate alerts + remediation timestamps.

## What goes in `evidence/`

Per release:
```
evidence/v0.X.Y-2026-MM-DD/
  ci-results.sarif         # CodeQL / Scorecard scan output
  sbom-cyclonedx.json
  sbom-spdx.json
  slsa-provenance.intoto.jsonl
  cosign-signatures.txt    # cosign verify output
  dependency-audit.json    # pnpm/pip audit
```

Auto-populated by `.github/workflows/release.yml`.
