# .husky/ — Git Hooks

> Installed by `pnpm install` via the `prepare` script.

---

## Hooks present

| Hook | Runs | What it checks |
|---|---|---|
| `pre-commit` | Before every commit | `prettier --check`, ESLint, `tsc --noEmit` (and `ruff` if Python) |
| `commit-msg` | After commit message written | commitlint (Conventional Commits) |

## How they get installed

`package.json` declares:

```json
{
  "scripts": {
    "prepare": "husky"
  },
  "devDependencies": {
    "husky": "^9.0.0",
    "@commitlint/cli": "^19.0.0",
    "@commitlint/config-conventional": "^19.0.0"
  }
}
```

When you run `pnpm install`, `prepare` fires and Husky installs the hooks defined in this folder into `.git/hooks/`.

## Bypassing (DO NOT, unless you must)

```bash
git commit --no-verify    # Skips pre-commit AND commit-msg
```

If a hook is failing legitimately, fix the underlying issue or update the hook — don't bypass.

## Adding a new hook

1. Create `<hook-name>` (no extension) in this folder (e.g., `pre-push`).
2. Make it executable: `chmod +x .husky/<hook-name>`.
3. Start it with the husky preamble (copy from existing hooks).
4. Commit.

Husky will install it on next `pnpm install`.

## Windows note

Husky uses POSIX shell. On Windows it runs via Git Bash (bundled with Git for Windows). Make sure your hooks use `sh`-compatible syntax.
