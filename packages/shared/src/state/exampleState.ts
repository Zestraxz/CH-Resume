/**
 * Example state machine. Replace with real domain transitions.
 */

export const EXAMPLE_STATUS = {
  PENDING: 'PENDING',
  IN_PROGRESS: 'IN_PROGRESS',
  COMPLETED: 'COMPLETED',
  CANCELLED: 'CANCELLED',
} as const;

export type ExampleStatus = (typeof EXAMPLE_STATUS)[keyof typeof EXAMPLE_STATUS];

const TRANSITIONS: Record<ExampleStatus, readonly ExampleStatus[]> = {
  PENDING:     ['IN_PROGRESS', 'CANCELLED'],
  IN_PROGRESS: ['COMPLETED', 'CANCELLED'],
  COMPLETED:   [],
  CANCELLED:   [],
};

export function canTransition(from: ExampleStatus, to: ExampleStatus): boolean {
  return TRANSITIONS[from].includes(to);
}
