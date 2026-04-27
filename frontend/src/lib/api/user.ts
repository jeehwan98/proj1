import { extractErrorMessage, fetchWithAuth } from "./fetch";

export type AuthProvider = "LOCAL" | "GITHUB" | "GOOGLE";

export interface UserProfile {
  id: number;
  name: string;
  email: string;
  role: string;
  provider: AuthProvider;
}

export async function getMe(): Promise<UserProfile> {
  const res = await fetchWithAuth("/users/me");
  if (!res.ok) throw new Error("Failed to fetch profile");
  return res.json();
}

export async function updateName(name: string): Promise<void> {
  const res = await fetchWithAuth("/users/me/name", {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name }),
  });
  if (!res.ok) await extractErrorMessage(res, "Failed to update name");
}

export async function changePassword(currentPassword: string, newPassword: string): Promise<void> {
  const res = await fetchWithAuth("/users/me/password", {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ currentPassword, newPassword }),
  });
  if (!res.ok) await extractErrorMessage(res, "Failed to change password");
}

export async function deleteAccount(): Promise<void> {
  const res = await fetchWithAuth("/users/me", { method: "DELETE" });
  if (!res.ok) throw new Error("Failed to delete account");
}
