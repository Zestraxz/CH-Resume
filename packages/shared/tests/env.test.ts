import { describe, expect, it } from 'vitest';

import { serverSchema } from '../src/env';

describe('serverSchema', () => {
  const validBase = {
    NODE_ENV: 'development',
    DATABASE_URL: 'postgresql://user:pass@localhost:5432/db',
    REDIS_URL: 'redis://localhost:6379',
    JWT_SECRET: 'a'.repeat(48),
    SESSION_SECRET: 'b'.repeat(48),
    CORS_ORIGINS: 'http://localhost:3000',
  };

  it('accepts a valid env', () => {
    const result = serverSchema.safeParse(validBase);
    expect(result.success).toBe(true);
  });

  it('rejects short JWT_SECRET', () => {
    const result = serverSchema.safeParse({ ...validBase, JWT_SECRET: 'short' });
    expect(result.success).toBe(false);
  });

  it('rejects missing DATABASE_URL', () => {
    const { DATABASE_URL: _omit, ...rest } = validBase;
    const result = serverSchema.safeParse(rest);
    expect(result.success).toBe(false);
  });

  it('rejects non-URL DATABASE_URL', () => {
    const result = serverSchema.safeParse({ ...validBase, DATABASE_URL: 'not-a-url' });
    expect(result.success).toBe(false);
  });

  it('transforms CORS_ORIGINS to array', () => {
    const result = serverSchema.safeParse({
      ...validBase,
      CORS_ORIGINS: 'http://a.com, http://b.com',
    });
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.CORS_ORIGINS).toEqual(['http://a.com', 'http://b.com']);
    }
  });

  it('defaults LLM_DAILY_BUDGET_USD when omitted', () => {
    const result = serverSchema.safeParse(validBase);
    if (result.success) {
      expect(result.data.LLM_DAILY_BUDGET_USD).toBe(10);
    }
  });
});
