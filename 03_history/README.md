# 03_history — Read-Only Snapshots

> Versioned past states. Recovery only. **Don't edit.**

---

## What goes here

- Snapshots of `02_active/` files when a phase ships
- Reference assets that were once load-bearing but are now superseded
- Old `PHASE<N>_NOTES.md` after phase exit
- Pre-rewrite source code (when keeping a rollback path makes sense)
- Old PDFs, design files, research that informed current decisions

## What does NOT go here

- Active code (use `apps/`, `packages/`, `src/`)
- Things you might still need to edit (use `02_active/`)
- Long-dead code with no recovery value (delete it or move to `05_archive/`)

## Naming convention

```
03_history/
├── PHASE1_NOTES.md
├── PHASE2_NOTES.md
├── reference-assets/
│   ├── 2026-Q1-design-research.pdf
│   └── original-state-machine.png
└── snapshots/
    └── 2026-04-15-pre-monorepo-restructure/
        └── ... (frozen subtree)
```

## When to promote OUT of history

If you find yourself reading something here regularly, it belongs in `02_active/` or `docs/`. Move it.

## When to demote TO archive

If something here has gone untouched for 6+ months and you genuinely don't expect to need it, move to `05_archive/`.
