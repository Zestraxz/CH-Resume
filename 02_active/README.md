# 02_active — Current Load-Bearing Reference

> Living docs for the project as it stands today. Edit freely.

---

## Contents

| File | Purpose |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | How the system is built — modules, data flow, contracts |
| [ROADMAP.md](ROADMAP.md) | Phases, milestones, dependencies |
| [ISSUES_AND_LEARNINGS.md](ISSUES_AND_LEARNINGS.md) | Pitfalls encountered, decisions reversed, gotchas — read this before debugging anything weird |
| `PHASE<N>_NOTES.md` | Per-phase notes; create new file when phase ships |

## When to edit what

- **Architecture changed** → update [ARCHITECTURE.md](ARCHITECTURE.md), record reason in an ADR ([../docs/04-quality/adr/](../docs/04-quality/adr/))
- **Phase progressed** → update [ROADMAP.md](ROADMAP.md) and [../STATUS.md](../STATUS.md)
- **Hit a sharp edge** → append to [ISSUES_AND_LEARNINGS.md](ISSUES_AND_LEARNINGS.md)
- **Started new phase** → create `PHASE<N>_NOTES.md`

## When to move things out

Once a phase ships fully and is no longer being actively iterated on, move its `PHASE<N>_NOTES.md` to [../03_history/](../03_history/) so this folder stays small.
