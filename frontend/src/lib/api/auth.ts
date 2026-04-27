import { extractErrorMessage } from "./fetch";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api";

export async function forgotPassword(email: string): Promise<void> {
  const res = await fetch(`${API_URL}/auth/forgot-password`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email }),
  });
  if (!res.ok) await extractErrorMessage(res, "Failed to send reset code");
}

export async function resetPassword(email: string, code: string, newPassword: string): Promise<void> {
  const res = await fetch(`${API_URL}/auth/reset-password`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, code, newPassword }),
  });
  if (!res.ok) await extractErrorMessage(res, "Failed to reset password");
}

export async function loginUser(email: string, password: string): Promise<void> {
  const res = await fetch(`${API_URL}/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify({ email, password }),
  });
  if (!res.ok) await extractErrorMessage(res, "Invalid email or password");
}

export async function registerUser(name: string, email: string, password: string): Promise<void> {
  const res = await fetch(`${API_URL}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name, email, password }),
  });
  if (!res.ok) await extractErrorMessage(res, "Registration failed");
}

export async function verifyUser(email: string, code: string): Promise<void> {
  const res = await fetch(`${API_URL}/auth/verify`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, code }),
  });
  if (!res.ok) await extractErrorMessage(res, "Verification failed");
}
