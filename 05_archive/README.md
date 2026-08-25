# 05_archive — Locked Legacy

> Historical reference. **Do not touch.**

---

## Rules

1. **Read only.** Open, learn, leave.
2. **Never refactor.** Don't "modernize," don't reformat, don't reorganize.
3. **Never reference from active code.** If active code imports from here, that's a bug — copy what you need to `02_active/` or active source paths.
4. **Never delete without owner sign-off.** This folder exists because we needed it once and might need it again.

## What goes here

- Pre-rewrite code (the old stack that was replaced)
- Old prototype branches collapsed into a snapshot
- Discontinued features kept for forensic / legal / audit reasons
- Approaches that were tried and abandoned (with a note explaining why, in `<thing>/WHY_ARCHIVED.md`)

## What does NOT go here

- Code under active development (use `apps/`, `packages/`, `src/`)
- Recent past you might still read (use `03_history/`)
- Forever-dead code that you're confident in deleting (just `git rm`)

## When something in here becomes interesting again

Don't edit it in place. Copy what you need to active locations, document the resurrection in an ADR, and leave the archived copy untouched.

## CODEOWNERS

This folder requires owner approval for any change in [CODEOWNERS](../CODEOWNERS).
