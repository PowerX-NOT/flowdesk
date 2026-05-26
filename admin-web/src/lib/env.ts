export const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL ?? '').toString().trim();

function join(a: string, b: string) {
  if (!a) return b;
  if (a.endsWith('/') && b.startsWith('/')) return a.slice(0, -1) + b;
  if (!a.endsWith('/') && !b.startsWith('/')) return a + '/' + b;
  return a + b;
}

export function apiUrl(path: string) {
  return join(API_BASE_URL, path);
}

