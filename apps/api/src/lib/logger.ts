/**
 * Structured logger with OpenTelemetry trace correlation.
 *
 * Pino 9+ auto-injects traceId / spanId from active OTel context.
 *
 * Usage:
 *   import { logger } from './lib/logger';
 *   logger.info({ userId, action: 'create' }, 'user.created');
 *
 *   // request-scoped child with correlation ID:
 *   const reqLogger = logger.child({ requestId: req.id });
 *   reqLogger.info('processing request');
 */

import { pino, type LoggerOptions } from 'pino';

const isProd = process.env.NODE_ENV === 'production';
const isTest = process.env.NODE_ENV === 'test';

const baseOptions: LoggerOptions = {
  level: process.env.LOG_LEVEL ?? (isProd ? 'info' : 'debug'),
  // Auto-redact common sensitive fields
  redact: {
    paths: [
      'password',
      '*.password',
      'token',
      '*.token',
      'authorization',
      'req.headers.authorization',
      'req.headers.cookie',
    ],
    censor: '[REDACTED]',
  },
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  serializers: pino.stdSerializers,
};

// Pretty-print in dev, JSON in prod
const transport = isProd || isTest
  ? undefined
  : {
      target: 'pino-pretty',
      options: {
        colorize: true,
        translateTime: 'SYS:HH:MM:ss.l',
        ignore: 'pid,hostname',
      },
    };

export const logger = pino({
  ...baseOptions,
  ...(transport ? { transport } : {}),
});

// Re-export for typed child loggers
export type Logger = typeof logger;
