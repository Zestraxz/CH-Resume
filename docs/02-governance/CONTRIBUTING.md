# Contributing to Resume

---

## TL;DR

1. Branch off `main` with a prefix: `feat/`, `fix/`, `chore/`, `docs/`.
2. Make changes. Run `pnpm precommit` before pushing.
3. Open a PR using the template (filled out).
4. Wait for CI green + CODEOWNERS approval.
5. Squash-merge.

## Before you start

- Read [../../CLAUDE.md](../../CLAUDE.md) — code conventions
- Read [GOVERNANCE.md](GOVERNANCE.md) — decision-making, roles
- Read [../../02_active/ISSUES_AND_LEARNINGS.md](../../02_active/ISSUES_AND_LEARNINGS.md) — known pitfalls
- Check [../../STATUS.md](../../STATUS.md) — is this aligned with the current phase?

## Workflow

```bash
git checkout -b feat/<short-name>
# ... work ...
pnpm precommit                         # format + lint + typecheck + test
git add <specific files>
git commit -m "feat(scope): subject"   # Conventional Commits
git push -u origin feat/<short-name>
gh pr create --template default        # or via GitHub UI
```

## Commit messages

Conventional Commits, please:

```
<type>(<scope>): <subject>
```

- **type:** `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`, `ci`
- **scope:** the area touched (`api`, `web`, `shared`, `docs`, `infra`, etc.)
- **subject:** imperative, ≤ 72 chars, no period

Body is optional but encouraged for non-trivial changes. Link issues with `Refs: #N` or `Closes: #N`.

## PR requirements

| Required | Check |
|---|---|
| Green CI | Auto |
| 1 CODEOWNERS approval | Auto-assigned |
| Updated `CHANGELOG.md` | Add bullet under `[Unreleased]` |
| Updated `STATUS.md` if phase progressed | Manual |
| ADR if architecture changed | See [../04-quality/adr/](../04-quality/adr/) |

## Code style

| Lang | Standard |
|---|---|
| TS / JS | Prettier (`.prettierrc`) + ESLint (auto-fix in CI) |
| Python | ruff (`pyproject.toml`) — format + lint in one tool |
| Markdown | Prettier (no specific linter; keep lines reasonable) |
| SQL | Lowercase keywords, snake_case identifiers, one statement per migration |

## What to NOT do

- Don't `git add -A` or `git add .` (stage specific files only)
- Don't commit `.env` (gitignored — but double-check)
- Don't `git push --force` to a shared branch
- Don't bypass linters (`--no-verify`)
- Don't introduce a new dependency without an ADR

## Reviewing PRs

- Read the diff top-to-bottom before commenting (don't drive-by)
- Ask "why" before "wat" — there's usually a reason
- Suggest, don't demand (unless it's a real bug)
- Approve when:
  - CI green
  - Code does what the PR says
  - Tests cover the new behavior
  - No new dependencies without ADR
  - Style matches the rest of the codebase

## Need help?

- Ping in the project channel
- Open a draft PR and ask
- Open an issue using the [question template](../../.github/ISSUE_TEMPLATE/bug.md)
