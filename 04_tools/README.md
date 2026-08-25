# 04_tools — Production-Validated Ops Automation

> Battle-tested utility scripts and infra config. Refactor cautiously.

---

## Contents

| Path | Role |
|---|---|
| `GitPush.ps1` / `GitPush.sh` | Safe git push (lint + test gate before push) |
| `infra/postgres/init-readonly-role.sql` | DB role bootstrap for read-only analytics |
| `infra/nginx/` | Production reverse-proxy config |
| `infra/k8s/` | Kubernetes manifests (if applicable) |
| `backup/` | DB backup + restore scripts |

## When to add here

A script earns its place in `04_tools/` when:

1. It's been used successfully in production (not just dev)
2. It handles failure gracefully (idempotent, errors loud, exit codes meaningful)
3. It has either a README section or inline docstring explaining usage + caveats
4. It's owned (CODEOWNERS points to a maintainer)

Until then, keep it in `scripts/` (lifecycle scripts) or `01_setup/` (bootstrap).

## When NOT to refactor

- Don't "modernize" `GitPush.ps1` without a real bug — it works
- Don't change SQL initialization scripts without a migration story
- Don't change infra without testing on a throwaway environment

## CODEOWNERS

This folder is owned in [CODEOWNERS](../CODEOWNERS). PRs touching `04_tools/` require explicit review.
