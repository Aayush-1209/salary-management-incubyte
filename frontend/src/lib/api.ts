// API base URL — uses Vite proxy in dev (/api → http://localhost:3000/api)
// Uses VITE_API_BASE_URL env var in production (set on Render)
const API_BASE = import.meta.env.VITE_API_BASE_URL ?? ''

async function request<T>(path: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      ...options?.headers,
    },
    ...options,
  })

  if (!response.ok) {
    const error = await response.json().catch(() => ({ message: 'Request failed' }))
    throw new ApiError(response.status, error.message ?? 'Request failed', error)
  }

  if (response.status === 204) return undefined as T
  return response.json() as Promise<T>
}

export class ApiError extends Error {
  public readonly status: number;
  public readonly body?: unknown;

  constructor(
    status: number,
    message: string,
    body?: unknown,
  ) {
    super(message)
    this.name = 'ApiError'
    this.status = status;
    this.body = body;
  }
}

export const api = {
  get: <T>(path: string) => request<T>(path),
  post: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'POST', body: JSON.stringify(body) }),
  patch: <T>(path: string, body: unknown) =>
    request<T>(path, { method: 'PATCH', body: JSON.stringify(body) }),
}
