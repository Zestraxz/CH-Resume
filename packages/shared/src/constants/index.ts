/**
 * Shared constants — limits, timeouts, role names that apps must agree on.
 */

export const REQUEST_TIMEOUT_MS = 30_000;
export const MAX_PAGE_SIZE = 100;
export const DEFAULT_PAGE_SIZE = 25;

export const ROLES = {
  ADMIN: 'ADMIN',
  USER: 'USER',
} as const;

export type Role = (typeof ROLES)[keyof typeof ROLES];
