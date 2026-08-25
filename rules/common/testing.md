# Common Testing Rules

> Applies to all languages. Override in `rules/<domain>/testing.md`.

---

## What to test

- **Behavior, not implementation.** A test should still pass after a refactor that doesn't change behavior.
- **Public API.** Test the entry points your callers use, not the private helpers.
- **Edge cases.** Empty, null, max, concurrent, malformed input. Tests for happy path only = false confidence.
- **Error paths.** Every `throw` site deserves a test.

## What NOT to test

- Framework code (trust your dependencies).
- Trivial getters / setters (no logic = no test).
- Implementation details you'll refactor (test the contract, not the steps).

## Structure

```
tests/
├── unit/              # No I/O. Fast (< 100ms each). Most of your tests.
├── integration/       # Real DB / cache / queue. Slower (< 5s each).
└── e2e/               # Full stack via HTTP / browser. Slowest. Few of these.
```

Mirror source paths: `src/lib/foo.ts` → `tests/unit/lib/foo.test.ts`.

## Conventions

- **Test names = sentences.** `it('returns 404 when user not found')`, not `it('test_user_404')`.
- **Arrange / Act / Assert** structure, visually separated.
- **No `setTimeout`, `setInterval`** — flaky. Use fake timers or events.
- **No random / time** in test inputs unless seeded.
- **No shared mutable state** between tests.
- **One assertion per test** (loose rule — multiple OK if testing one behavior).

## Coverage

- Target: {{COVERAGE_MIN}}% line coverage for new code.
- Coverage is a signal, not a goal. 100% covered + still buggy is possible.
- Prefer **one good test of behavior** over five tests-for-coverage.

## Mocking

- Mock at boundaries (HTTP, DB, time). Don't mock your own code's internals.
- Use real Postgres in integration tests (testcontainers). Don't mock the DB and call it "integration."
- Use frozen time (`vi.useFakeTimers()` / `freezegun`).

## CI

- Tests run on every PR.
- Coverage gate fails the build below threshold.
- Test artifacts (junit, coverage HTML) uploaded for failed runs.

## Anti-patterns

- ❌ Tests that depend on test order
- ❌ Tests that fail intermittently ("flaky" = bug, fix immediately or quarantine)
- ❌ Tests that take > 1s for "unit" tests
- ❌ `expect(true).toBe(true)` placeholders left in code
- ❌ `skip` or `only` left in committed code (lint rule should catch)
