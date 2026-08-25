# Changesets

> Monorepo-aware release automation. Decouples versioning from commit messages.

---

## Workflow

```bash
# When you make a user-facing change, create a changeset:
pnpm changeset

# Pick affected packages, pick major/minor/patch, write summary.
# Commits a .changeset/<random-name>.md file describing the change.

# Maintainer runs (typically via CI on main):
pnpm changeset version  # bumps package versions + updates CHANGELOGs
pnpm changeset publish  # publishes to npm
```

## What goes here

- `config.json` - changeset configuration (committed)
- `<random>.md` files - one per unreleased change (committed; consumed on version)

## CI integration

Suggested workflow:

```yaml
# .github/workflows/release.yml
- uses: changesets/action@v1
  with:
    publish: pnpm changeset publish
    version: pnpm changeset version
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

When changesets exist on `main`, the action opens a "Release PR" with bumped versions + collated CHANGELOG entries. Merging the PR triggers publish.

## Why not semantic-release?

- semantic-release only handles single packages well; monorepo plugin unmaintained since 2022.
- changesets decouples intent (the .md file) from commit messages - cleaner monorepo experience.

## Why not release-please (Google)?

Both work. release-please is fine for polyglot monorepos. changesets is more idiomatic for pnpm/yarn workspaces. Pick one and stick.
