/**
 * Domain types. Prefer inferring from schemas (zod) over hand-writing.
 *
 * Re-export type aliases here for convenient app-side imports:
 *   import type { Example } from '@resume/shared/types';
 */

export type { Example } from '../schemas/example';
export type { ExampleStatus } from '../state/exampleState';
