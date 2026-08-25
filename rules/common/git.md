# Common Git Rules

---

## Branches

- `main` is protected. PRs only.
- Branch naming: `<type>/<short-desc>` (e.g., `feat/cases-endpoint`, `fix/null-deref`).
- Delete branches after merge.

## Commits

- **Conventional Commits.** `<type>(<scope>): <subject>` — see [../../docs/02-governance/CONTRIBUTING.md](../../docs/02-governance/CONTRIBUTING.md).
- **One logical change per commit.** Don't bundle "fix bug + reformat half the file."
- **Imperative subject.** "add endpoint" not "added endpoint" or "adds endpoint."
- **≤ 72 char subject.** Body wrapped at 72 if used.

## Staging

- **Always stage specific files.** Never `git add -A` or `git add .` (catches `.env`, build artifacts, secrets).
- Use `git status --short` first to know what you're about to stage.

## Forbidden

- ❌ `git push --force` to shared branches (use `--force-with-lease` if you must; never to `main`)
- ❌ `--no-verify` (skips hooks — fix the hook failure instead)
- ❌ `git reset --hard <upstream>` without `git stash` first
- ❌ Committing `.env`, `node_modules`, build outputs
- ❌ Editing published commits (rewriting history that others have based work on)

## When hooks fail

1. Read the error.
2. Fix the underlying issue.
3. `git add <fixed files>`.
4. New commit. **Don't `--amend`** (the previous commit didn't happen — amending modifies the prior one).

## Tags

- SemVer: `v<major>.<minor>.<patch>`.
- Sign tags for releases: `git tag -s v1.2.3`.

## Force-push protocol

If absolutely required:
1. Confirm no one else has based work on the soon-to-be-rewritten commits.
2. Use `--force-with-lease`, not `--force`.
3. Notify everyone affected before pushing.
4. Never to `main` / `master` / `production`.
