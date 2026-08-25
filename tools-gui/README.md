# tools-gui/ — One-Click GUI Launchers

> Double-click any `.cmd` here. A small Windows Forms wizard opens. Fill, click, done.

---

## What ships here

| Launcher | Profile | Purpose |
|---|---|---|
| `Setup-Env.cmd` | all | First-run env setup: reads `.env.example`, opens a form with one field per variable, writes `.env`. Auto-generates random secrets for `JWT_SECRET`, `SESSION_SECRET` |
| `GitPush.cmd` | all | Commit wizard: type-scope-subject dropdowns (Conventional Commits), changed-files checklist, optional body/footer, skip-test toggle. Wraps `04_tools/GitPush.ps1` |
| `New-ADR.cmd` | all | New Architecture Decision Record: title + status + supersedes. Auto-numbers, copies template, opens in editor |
| `New-RFC.cmd` | standard+ | New Request for Comments: title + related-to. Auto-numbers, copies `rfcs/0000-template.md`, opens in editor |
| `Upgrade-Profile.cmd` | standard+ | Compares current profile to higher profile; generates a diff report into `02_active/profile-upgrade-report.md`. Read it, copy what you want |

## The convention these follow

**GUI when there are choices. 1-click `.cmd` when there aren't.**

- `START_HERE.cmd` (project root) — no GUI; just runs bootstrap. There's nothing to choose.
- `OPEN_ARTIFACTS.cmd` (project root) — same, no GUI.
- Anything in `tools-gui/` — GUI, because the user is providing inputs.

See `PRINCIPLES.md` §19 in the meta-template for the rationale.

## Anatomy of a launcher

Two files per launcher:

1. **`<Name>.cmd`** — double-click target. Thin batch wrapper:
   ```cmd
   @echo off
   setlocal
   powershell -NoProfile -ExecutionPolicy Bypass -STA -WindowStyle Hidden -File "%~dp0<Name>.ps1"
   endlocal & exit /b %ERRORLEVEL%
   ```

2. **`<Name>.ps1`** — WinForms front-end. Self-relaunches in `-STA` if invoked another way.

Both stay together in `tools-gui/`. The `.cmd` is for File Explorer; the `.ps1` does the work.

## Adding your own GUI launcher

When you find yourself reaching for the CLI three times for the same task with the same kind of choices, build one:

1. Copy `Setup-Env.{cmd,ps1}` to `<NewTask>.{cmd,ps1}`.
2. Edit the form to ask for what you need.
3. Have the click handler call your existing PowerShell script (don't reimplement logic).
4. Test by double-clicking the `.cmd`.

The pattern: **GUI is a thin front-end to existing scripts.** Never duplicate business logic inside the form.

## Rules these all follow (from AGENTS.md)

- ASCII only in `.ps1` files (no em-dashes, no smart quotes — PS5.1 + UTF-8-without-BOM hates them)
- No backticks inside double-quoted strings (use single-quoted literals)
- `Test-Path 'x' -or Y` always paren-wrapped
- WinForms requires `-STA` mode (the `.cmd` wrapper passes it)

## Don't put here

- Tasks with no choices to make → `START_HERE.cmd` style (no GUI)
- One-off ad-hoc scripts → `04_tools/`
- Build / test / lint → `package.json` scripts; CI runs them too
- Hook scripts → `hooks/`
- Anything CI-only → `.github/workflows/`
