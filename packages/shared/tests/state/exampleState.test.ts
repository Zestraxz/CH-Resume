import { describe, expect, it } from 'vitest';

import { canTransition, EXAMPLE_STATUS } from '../../src/state/exampleState';

describe('exampleState', () => {
  it('allows PENDING -> IN_PROGRESS', () => {
    expect(canTransition(EXAMPLE_STATUS.PENDING, EXAMPLE_STATUS.IN_PROGRESS)).toBe(true);
  });

  it('allows PENDING -> CANCELLED', () => {
    expect(canTransition(EXAMPLE_STATUS.PENDING, EXAMPLE_STATUS.CANCELLED)).toBe(true);
  });

  it('forbids PENDING -> COMPLETED (must go through IN_PROGRESS)', () => {
    expect(canTransition(EXAMPLE_STATUS.PENDING, EXAMPLE_STATUS.COMPLETED)).toBe(false);
  });

  it('forbids transitions out of terminal states', () => {
    expect(canTransition(EXAMPLE_STATUS.COMPLETED, EXAMPLE_STATUS.PENDING)).toBe(false);
    expect(canTransition(EXAMPLE_STATUS.CANCELLED, EXAMPLE_STATUS.IN_PROGRESS)).toBe(false);
  });
});
