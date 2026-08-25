import { z } from 'zod';

/**
 * Example schema. Replace with real domain entities.
 *
 * @example
 *   const parsed = exampleSchema.parse({ id: 'abc', name: 'Test' });
 */
export const exampleSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1).max(120),
  createdAt: z.coerce.date(),
});

export type Example = z.infer<typeof exampleSchema>;
