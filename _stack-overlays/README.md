# _stack-overlays/

> Stack-specific files copied into the scaffolded project AFTER profile trim, by the init script.

---

Each subfolder is a stack name (`vite-flat`, ...). When `-Stack vite-flat` is selected, every file under `_stack-overlays/vite-flat/` is copied to the project root (with `{{PLACEHOLDER}}` substitution) AFTER the regular trim runs.

This is how stack-specific *additions* work — the regular `template/` base ships the union of all stacks; overlays add things ONLY when the matching stack is selected.

## Currently shipped overlays

| Stack | Purpose | Files |
|---|---|---|
| `vite-flat` | AI-Studio / flat-root Vite + React layout (App.tsx and components/hooks/utils at project root, no `src/`) | App.tsx, components/, hooks/, utils/, services/, types.ts, constants.ts, index.html, index.tsx, metadata.json, vite.config.ts, tsconfig.json |

## Adding a new stack overlay

1. Add the stack name to the `-Stack` ValidateSet in `init/New-Project.ps1` and `init/new-project.sh`.
2. Add a trim case in the same scripts (which base files to remove for this stack).
3. Create `template/_stack-overlays/<stack-name>/` and drop in the stack-specific files.
4. Smoke-test via `01_setup/verify-template.ps1`.
