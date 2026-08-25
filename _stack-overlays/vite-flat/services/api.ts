/**
 * Single entry point for ALL API calls. Components import from here only.
 * Never bare fetch() in components - it makes auth/error/retry handling impossible
 * to centralize.
 */

import { API_BASE_URL } from '../constants';

class ApiError extends Error {
  constructor(message: string, public status: number, public url: string) {
    super(message);
    this.name = 'ApiError';
  }
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const url = `${API_BASE_URL}${path}`;
  const res = await fetch(url, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(init?.headers ?? {}),
    },
  });
  if (!res.ok) {
    throw new ApiError(`HTTP ${res.status} on ${path}`, res.status, url);
  }
  return (await res.json()) as T;
}

export const api = {
  get:    <T>(path: string)                  => request<T>(path),
  post:   <T>(path: string, body: unknown)   => request<T>(path, { method: 'POST', body: JSON.stringify(body) }),
  put:    <T>(path: string, body: unknown)   => request<T>(path, { method: 'PUT',  body: JSON.stringify(body) }),
  delete: <T>(path: string)                  => request<T>(path, { method: 'DELETE' }),
};

export { ApiError };
