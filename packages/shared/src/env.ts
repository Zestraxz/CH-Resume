/**
 * Env validation - fails at boot if env is malformed.
 *
 * Pattern stolen from @t3-oss/env-nextjs - the most-copied file in the TS ecosystem.
 *
 * Usage in apps:
 *   import { serverEnv } from '@resume/shared/env';
 *   const dbUrl = serverEnv.DATABASE_URL;  // type-safe; missing/invalid -> build fails
 *
 * Server-only vars MUST NOT be referenced from client bundles.
 * Client-exposed vars MUST be prefixed VITE_ (or NEXT_PUBLIC_ for Next.js).
 */

import { z } from 'zod';

// ---- Server-only schema -----------------------------------------------------
const serverSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be >= 32 chars'),
  SESSION_SECRET: z.string().min(32),
  CORS_ORIGINS: z.string().transform((s) => s.split(',').map((o) => o.trim())),

  // AI provider keys (optional; presence implies feature enabled)
  ANTHROPIC_API_KEY: z.string().optional(),
  OPENAI_API_KEY: z.string().optional(),

  // Cost guardrails
  LLM_DAILY_BUDGET_USD: z.coerce.number().positive().default(10),
  LLM_MAX_TOKENS_PER_REQUEST: z.coerce.number().int().positive().default(4096),
  LLM_BUDGET_ALERT_PCT: z.coerce.number().min(0).max(100).default(80),

  // Observability
  SENTRY_DSN: z.string().url().optional(),
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().url().optional(),
  OTEL_SERVICE_NAME: z.string().default('resume'),
});

// ---- Client-exposed schema (safe to bundle) --------------------------------
// Anything in this schema can leak to the public. Treat values as on a billboard.
const clientSchema = z.object({
  VITE_API_URL: z.string().url().optional(),
  VITE_FEATURE_FOO_ENABLED: z
    .enum(['true', 'false'])
    .default('false')
    .transform((s) => s === 'true'),
});

// ---- Parse + freeze --------------------------------------------------------
function parseEnv() {
  const isServer = typeof window === 'undefined';
  const isBuild = process.env.SKIP_ENV_VALIDATION === 'true';
  if (isBuild) {
    // CI build doesn't have real env; skip validation.
    return {
      server: process.env as unknown as z.infer<typeof serverSchema>,
      client: process.env as unknown as z.infer<typeof clientSchema>,
    };
  }

  const clientResult = clientSchema.safeParse(process.env);
  if (!clientResult.success) {
    console.error('CLIENT ENV INVALID:', clientResult.error.flatten());
    throw new Error('Invalid client env - refusing to start');
  }

  if (!isServer) {
    return { server: {} as z.infer<typeof serverSchema>, client: clientResult.data };
  }

  const serverResult = serverSchema.safeParse(process.env);
  if (!serverResult.success) {
    console.error('SERVER ENV INVALID:', serverResult.error.flatten());
    throw new Error('Invalid server env - refusing to start');
  }

  return { server: serverResult.data, client: clientResult.data };
}

const _env = parseEnv();
export const serverEnv = _env.server;
export const clientEnv = _env.client;

// Re-export schemas for tests
export { serverSchema, clientSchema };
