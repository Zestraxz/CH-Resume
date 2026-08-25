# research/

> Active research artifacts. Notes, exploration, ad-hoc analysis you're working through RIGHT NOW.

---

## Difference from `03_history/research/`

| Folder | Time | Mutable? | Read by |
|---|---|---|---|
| `research/` (this folder) | NOW | Yes - actively edited | You today |
| `03_history/research/` | PAST | No - frozen snapshots | Future you / contributors archaeology |

When a research artifact stops being actively edited and becomes a snapshot, move it to `03_history/research/<topic>-<date>/`.

## Suggested layout

```
research/
├── 2026-05-25-evaluating-prisma-vs-drizzle/
│   ├── notes.md
│   ├── benchmarks.csv
│   └── decision.md          # this often becomes an ADR when done
├── current-bottleneck-analysis/
│   ├── flamegraphs/
│   └── findings.md
└── README.md
```

## When research finishes

1. If it produced a decision -> write an ADR in `docs/04-quality/adr/`
2. Move the folder to `03_history/research/<topic>-<YYYY-MM-DD>/`
3. Update `02_active/STATUS.md` to mention the new direction (if applicable)
