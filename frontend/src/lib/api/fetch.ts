const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api";

export async function extractErrorMessage(res: Response, fallback: string): Promise<never> {
  const text = await res.text();
  if (text) {
    try {
      const { message } = JSON.parse(text);
      throw new Error(message || fallback);
    } catch (e) {
      if (e instanceof SyntaxError) throw new Error(fallback);
      throw e;
    }
  }
  throw new Error(fallback);
}

export async function fetchWithAuth(
  path: string,
  init?: RequestInit
): Promise<Response> {
  const res = await fetch(`${API_URL}${path}`, {
    ...init,
    credentials: "include",
  });

  if (res.status !== 401) return res;

  const refreshRes = await fetch(`${API_URL}/auth/refresh`, {
    method: "POST",
    credentials: "include",
  });

  if (!refreshRes.ok) {
    window.location.href = "/login";
    throw new Error("Session expired");
  }

  return fetch(`${API_URL}${path}`, {
    ...init,
    credentials: "include",
  });
}
