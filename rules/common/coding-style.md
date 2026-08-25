# Common Coding Style

> Applies to all languages. Override in `rules/<domain>/coding-style.md`.

---

## Universal rules

### Names
- Names are descriptive, not abbreviated. `userCount`, not `uc`.
- No type prefixes (`strName`, `bIsValid`).
- Files match the primary exported name (`UserCard.tsx` exports `UserCard`).

### Functions
- One thing per function. If you can't summarize in one sentence, split.
- ≤ 50 lines as a target; ≤ 100 as a hard limit.
- Pure when possible; side effects at the edges.

### Comments
- Default: **no comments**. Names should explain the *what*.
- Write a comment only when the *why* is non-obvious (a constraint, a workaround, a surprising invariant).
- Never restate code. `i++; // increment i` is noise.

### Errors
- Throw typed errors (`AppError` hierarchy), never bare `Error`.
- Don't swallow exceptions silently. Either handle or re-throw.
- Log at the boundary (request handler), not deep inside libraries.

### Logging
- Structured (JSON), never plain text in production.
- Include correlation ID per request.
- Levels: `debug` (verbose), `info` (notable), `warn` (recoverable), `error` (failed).

### Magic values
- Constants, not literals. `MAX_RETRIES = 3`, not `retry(3)`.
- Configuration via env, not hardcoded.

### Imports
- Absolute paths via alias (`@/lib/foo`), not relative `../../`.
- Group: stdlib → external → internal.
- Sort within groups (linter enforces).

## Anti-patterns

- ❌ Long files (> 500 lines without a structural reason)
- ❌ Long functions (> 100 lines)
- ❌ Deep nesting (> 4 levels — extract or flatten)
- ❌ Boolean-trap parameters (`doThing(true)` — use enums or named args)
- ❌ "Util" / "Helper" / "Misc" modules — name by domain instead
- ❌ Premature abstraction (3 similar things, not 2)
- ❌ Backward-compatibility shims for unreleased code
