# Resume — Developer Workflow

> Day-to-day commands and conventions. For the *why* see [CLAUDE.md](CLAUDE.md).

---

## Local setup

```bash
# One-shot bootstrap (Windows)
.\START_HERE.cmd

# One-shot bootstrap (Unix)
./01_setup/run.sh

# Manual
cp .env.example .env
docker compose up -d
pnpm install         # or: pip install -e ".[dev]"
pnpm dev             # or: python -m resume
```

## Daily loop

```bash
git pull --rebase
pnpm install              # if package.json changed
pnpm dev                  # start dev server
# ... code ...
pnpm format
pnpm lint
pnpm typecheck
pnpm test
git add <specific files>
git commit -m "feat(scope): short description"
git push
```

## Branching

- `main` — protected; releases tag from here
- `feat/<name>` — feature branches
- `fix/<name>` — bug fixes
- `chore/<name>` — refactor, deps, tooling
- `docs/<name>` — docs-only

PRs require:
- Green CI
- 1 maintainer approval (auto from CODEOWNERS)
- Updated CHANGELOG.md (Unreleased section)
- STATUS.md updated if phase progressed

## Commit message format

Conventional Commits:
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`, `ci`.

Example:
```
feat(api): add /cases/:id/audit endpoint

Returns append-only audit log for a case. Paginated, max 100 entries.

Refs: #42
```

## Pre-commit gate

Configure git to run this on every commit (one-time setup):

```bash
# .git/hooks/pre-commit (chmod +x)
#!/usr/bin/env bash
set -e
pnpm format
pnpm lint
pnpm typecheck
pnpm test
```

Or use husky / pre-commit framework — see [docs/02-governance/CONTRIBUTING.md](docs/02-governance/CONTRIBUTING.md).

## Common commands

| Command | What |
|---|---|
| `pnpm dev` | Start all apps in parallel watch mode |
| `pnpm build` | Production build all packages |
| `pnpm test` | Run all tests |
| `pnpm test:watch` | Watch mode |
| `pnpm test:coverage` | Coverage report |
| `pnpm typecheck` | TS strict check across all packages |
| `pnpm lint` / `pnpm lint:fix` | ESLint |
| `pnpm format` / `pnpm format:check` | Prettier |
| `pnpm precommit` | format + lint + typecheck + test |
| `pnpm clean` | Remove node_modules, dist, coverage |

## Debugging

- **Service won't start:** [docs/03-deployment/RUNBOOK.md](docs/03-deployment/RUNBOOK.md)
- **Tests flaky in CI:** check for unmocked time / network / random
- **Type errors after rebase:** `pnpm clean && pnpm install && pnpm typecheck`
- **Docker port conflict:** `docker compose down -v` then `docker compose up -d`

## Adding a dependency

1. Open an ADR if it's a load-bearing dep (framework, ORM, etc.): copy `docs/04-quality/adr/0001-*.md` → new number.
2. Add to the right `package.json` (root, app, or package).
3. Run `pnpm install`.
4. Commit `package.json` + `pnpm-lock.yaml` together.

## Releasing

1. Bump version in `package.json` / `pyproject.toml` (SemVer).
2. Move `[Unreleased]` entries to a new versioned section in `CHANGELOG.md` with date.
3. `git tag v0.X.Y && git push --tags`.
4. CI builds and publishes (see `.github/workflows/`).
