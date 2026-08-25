/**
 * Example unit test. Delete once you have real ones.
 *
 * Run with: `pnpm test` (Vitest)
 */

import { describe, expect, it } from 'vitest';

describe('example', () => {
  it('passes a sanity check', () => {
    expect(1 + 1).toBe(2);
  });

  it('demonstrates arrange / act / assert', () => {
    // Arrange
    const input = [3, 1, 2];

    // Act
    const result = [...input].sort();

    // Assert
    expect(result).toEqual([1, 2, 3]);
    expect(input).toEqual([3, 1, 2]); // original unchanged
  });
});
