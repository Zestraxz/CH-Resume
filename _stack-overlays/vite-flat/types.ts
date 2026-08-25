/**
 * Project-wide type definitions for Resume.
 * Add domain types here. Keep schemas (Zod) separate in services/ or schemas/.
 */

export interface User {
  id: string;
  name: string;
  email: string;
}

export type Status = 'idle' | 'loading' | 'success' | 'error';
