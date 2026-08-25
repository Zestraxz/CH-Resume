// =============================================================================
// Global test setup
// =============================================================================
// Runs once before any test. Use for:
//   - Setting up DOM polyfills (frontend)
//   - Mocking global APIs
//   - Configuring test database
//   - Setting timezone, locale, etc.
// =============================================================================

import { beforeAll, afterAll, afterEach } from 'vitest';

// ---- Timezone / locale (deterministic tests) -------------------------------
process.env.TZ = 'UTC';

// ---- DOM polyfills (uncomment if testing frontend) -------------------------
// import '@testing-library/jest-dom/vitest';

// ---- Mock fetch / time / random (uncomment as needed) ----------------------
// import { vi } from 'vitest';
// vi.useFakeTimers();

// ---- Lifecycle hooks -------------------------------------------------------
beforeAll(async () => {
  // global setup
});

afterEach(() => {
  // per-test cleanup
});

afterAll(async () => {
  // global teardown
});
