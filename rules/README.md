# rules/ — Layered AI Coding Standards

> Modular coding standards. `common/` is the base; domain folders override.

---

## Layout

```
rules/
├── common/                # Base rules (apply to all languages)
│   ├── coding-style.md
│   ├── testing.md
│   ├── security.md
│   └── git.md
├── web/                   # Frontend overrides (extends common/)
│   ├── coding-style.md
│   └── testing.md
├── python/                # Python overrides
│   └── coding-style.md
└── README.md
```

## How layering works

A rule file in `web/coding-style.md` typically starts with:

```markdown
# Web Coding Style

> Extends [../common/coding-style.md](../common/coding-style.md).
> Adds React-specific rules; common rules still apply unless overridden below.

## Overrides
- Use `.tsx` for components, `.ts` for utilities.
- Function components only (no class components).

## Additions
- Prefer `const` over `function` for top-level definitions.
- ...
```

## Loading rules

Rules are **not** auto-loaded by Claude Code. Reference them explicitly:

- From [../CLAUDE.md](../CLAUDE.md): "Follow `rules/common/coding-style.md` and `rules/web/coding-style.md`."
- From a slash command: "Apply standards in `rules/<domain>/`."
- From a skill: include rules content or reference paths in the body.

## Why layered?

- **DRY:** common rules (no `any`, no console.log, structured errors) apply everywhere; don't repeat.
- **Targeted:** language-specific quirks (Python's snake_case, React's component patterns) live in their own file.
- **Composable:** a Python web app loads `common/ + python/ + web/`.

## Best practices

- Keep each rule file < 200 lines
- Use `> Extends [../common/X.md](...)` headers to make inheritance explicit
- One rule per heading; concise prescriptive language ("Use X." not "It might be a good idea to...")
- Update rules when you find yourself correcting the same thing twice

## See also

- [../CLAUDE.md](../CLAUDE.md) — references which rule files apply
- [../docs/02-governance/TAXONOMY.md](../docs/02-governance/TAXONOMY.md) — naming + tag vocabulary
