# Workflow - Affected-only CI

> When the monorepo grows beyond ~3 packages, running every test on every PR becomes wasteful.
> Elite teams (Nx, Turbo) run only the tests for code paths affected by the diff.

---

## When to adopt

- Monorepo with 3+ packages
- CI time > 5 minutes on a typical PR
- Frequent PRs touching only one package

## Options

| Tool | Best for | Cost |
|---|---|---|
| [Nx](https://nx.dev) | TypeScript monorepos; full ecosystem | Free (Nx Cloud paid) |
| [Turborepo](https://turborepo.dev) | TypeScript monorepos; lighter than Nx | Free (Vercel Remote Cache paid) |
| [Bazel](https://bazel.build) | Polyglot monorepos; massive scale | Steep learning curve |
| [Pants](https://www.pantsbuild.org) | Python-heavy monorepos | Heavy |
| Custom (`git diff` + glob -> filter test paths) | Simple cases | Maintenance burden |

## Pattern (Nx example)

```yaml
# .github/workflows/ci.yml
- run: pnpm nx affected --target=test,lint,typecheck --base=origin/main
```

`nx affected` walks the project graph and runs only what changed (transitively).

## Pattern (Turbo example)

```yaml
- run: pnpm turbo run test lint typecheck --filter=...[origin/main]
```

## Caveats

- Affected detection assumes you've declared deps correctly. Hidden deps (env files, generated code) can produce false negatives.
- Always run full CI on main + nightly cron in addition to affected-only on PRs.
