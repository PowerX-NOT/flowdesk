import { apiUrl } from './env';
import type {
  TaskResponse,
  TokenResponse,
  UserResponse,
  TaskStatus,
} from './types';

const ACCESS_TOKEN_KEY = 'flowdesk_admin_access_token';
const REFRESH_TOKEN_KEY = 'flowdesk_admin_refresh_token';

export class ApiError extends Error {
  status: number;
  detail?: string;

  constructor(status: number, message: string, detail?: string) {
    super(message);
    this.status = status;
    this.detail = detail;
  }
}

export function getAccessToken(): string | null {
  return localStorage.getItem(ACCESS_TOKEN_KEY);
}

export function getRefreshToken(): string | null {
  return localStorage.getItem(REFRESH_TOKEN_KEY);
}

export function clearTokens() {
  localStorage.removeItem(ACCESS_TOKEN_KEY);
  localStorage.removeItem(REFRESH_TOKEN_KEY);
}

export function setTokens(tokens: TokenResponse) {
  localStorage.setItem(ACCESS_TOKEN_KEY, tokens.access_token);
  if (tokens.refresh_token) {
    localStorage.setItem(REFRESH_TOKEN_KEY, tokens.refresh_token);
  } else {
    localStorage.removeItem(REFRESH_TOKEN_KEY);
  }
}

async function refreshTokensIfPossible(): Promise<TokenResponse | null> {
  const refresh = getRefreshToken();
  if (!refresh) return null;

  const res = await fetch(apiUrl('/auth/refresh'), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ refresh_token: refresh }),
  });

  if (!res.ok) return null;
  const tokens = (await res.json()) as TokenResponse;
  setTokens(tokens);
  return tokens;
}

async function requestJson<T>(
  method: string,
  path: string,
  body?: unknown,
  accessToken?: string | null,
): Promise<T> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  };
  if (accessToken) headers['Authorization'] = `Bearer ${accessToken}`;

  const res = await fetch(apiUrl(path), {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!res.ok) {
    let detail: string | undefined;
    try {
      const data = await res.json();
      detail = data?.detail?.toString?.();
    } catch {
      // ignore parse errors
    }
    throw new ApiError(res.status, detail ?? `Request failed (${res.status})`, detail);
  }

  return (await res.json()) as T;
}

async function requestWithAuth<T>(
  method: string,
  path: string,
  body?: unknown,
): Promise<T> {
  const access = getAccessToken();
  try {
    return await requestJson<T>(method, path, body, access);
  } catch (e) {
    if (e instanceof ApiError && e.status === 401) {
      const refreshed = await refreshTokensIfPossible();
      if (refreshed?.access_token) {
        return await requestJson<T>(method, path, body, refreshed.access_token);
      }
    }
    throw e;
  }
}

export async function login(email: string, password: string): Promise<UserResponse> {
  const res = await fetch(apiUrl('/auth/login'), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ email, password }),
  });

  if (!res.ok) {
    let detail: string | undefined;
    try {
      const data = await res.json();
      detail = data?.detail?.toString?.();
    } catch {
      // ignore
    }
    throw new ApiError(res.status, detail ?? `Login failed (${res.status})`, detail);
  }

  const tokens = (await res.json()) as TokenResponse;
  setTokens(tokens);
  // Verify + get user profile
  return me();
}

export async function me(): Promise<UserResponse> {
  return requestWithAuth<UserResponse>('GET', '/users/me');
}

export interface AdminListUsersParams {
  skip?: number;
  limit?: number;
}

export async function adminListUsers(params: AdminListUsersParams = {}): Promise<UserResponse[]> {
  const skip = params.skip ?? 0;
  const limit = params.limit ?? 100;
  const path = `/users/?skip=${skip}&limit=${limit}`;
  return requestWithAuth<UserResponse[]>('GET', path);
}

export async function adminDeleteUser(userId: number): Promise<void> {
  await requestWithAuth<void>('DELETE', `/users/${userId}`);
}

export interface AdminListTasksParams {
  status?: TaskStatus;
  search?: string;
  skip?: number;
  limit?: number;
}

export async function adminListTasks(params: AdminListTasksParams = {}): Promise<TaskResponse[]> {
  const status = params.status;
  const search = params.search;
  const skip = params.skip ?? 0;
  const limit = params.limit ?? 200;

  const qs = new URLSearchParams();
  if (status) qs.set('status', status);
  if (search) qs.set('search', search);
  qs.set('skip', String(skip));
  qs.set('limit', String(limit));

  const path = `/tasks/admin?${qs.toString()}`;
  return requestWithAuth<TaskResponse[]>('GET', path);
}

export async function adminUpdateTaskStatus(taskId: number, status: TaskStatus): Promise<TaskResponse> {
  return requestWithAuth<TaskResponse>('PUT', `/tasks/admin/${taskId}`, { status });
}

export async function adminDeleteTask(taskId: number): Promise<void> {
  await requestWithAuth<void>('DELETE', `/tasks/admin/${taskId}`);
}

