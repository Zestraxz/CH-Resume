# Changelog

All notable changes to Resume will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- `tools-gui/` folder with one-click GUI launchers per PRINCIPLES.md Sec 19. WinForms via PowerShell; double-click any `.cmd` to open. Each GUI forwards selections to existing scripts (thin front-end pattern).
  - `Setup-Env.cmd` - fill `.env` from `.env.example`
  - `GitPush.cmd` - Conventional Commits wizard
  - `New-ADR.cmd` - auto-numbered ADR from template
  - `New-RFC.cmd` (standard+) - auto-numbered RFC
  - `Upgrade-Profile.cmd` (standard+) - profile-diff report

### Changed
- _(pending)_

### Fixed
- _(pending)_

---

## [0.1.0] - YYYY-MM-DD

### Added
- Initial scaffold from CH Project Architecture template v1.2.0.
- Numbered lifecycle folders, numbered docs tree.
- AGENTS.md (canonical) + CLAUDE.md (pointer) + copilot-instructions.md (pointer) per 2026 AGENTS.md spec.
- `.cursor/rules/` with MDC frontmatter; `.mcp.json` at root.
- Zod (TS) / Pydantic (Py) env validation that fails build on bad env.
- ESLint architectural boundaries (`no-restricted-imports`).
- AI security baseline: prompt injection, PII scrubbing, cost guardrails.
- `evals/` for LLM output snapshot tests.
- (standard) Structurizr C4 + arc42 12-section skeleton + Tech Radar + tradeoffs + sustainability docs.
- (standard) MkDocs Material docs site + reusable workflow + DORA emitter + catalog-info.yaml.
- (enterprise) SLSA L3 release pipeline + SBOM (CycloneDX + SPDX) + Cosign + compliance folder + STRIDE threat model + OpenSLO.

[Unreleased]: # "Pending"
[0.1.0]: # "Initial scaffold from template v1.2.0"
