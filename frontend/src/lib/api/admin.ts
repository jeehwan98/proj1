import { extractErrorMessage, fetchWithAuth } from "./fetch";
import type { UserProfile } from "./user";

export interface PageResponse<T> {
  content: T[];
  totalPages: number;
  totalElements: number;
  number: number;
  size: number;
}

export async function getUsers(page = 0, size = 20): Promise<PageResponse<UserProfile>> {
  const res = await fetchWithAuth(`/admin/users?page=${page}&size=${size}&sort=id`);
  if (!res.ok) await extractErrorMessage(res, "Failed to fetch users");
  return res.json();
}

export async function adminUpdateName(userId: number, name: string): Promise<void> {
  const res = await fetchWithAuth(`/admin/users/${userId}/name`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ name }),
  });
  if (!res.ok) await extractErrorMessage(res, "Failed to update name");
}

export async function adminUpdateRole(userId: number, role: string): Promise<void> {
  const res = await fetchWithAuth(`/admin/users/${userId}/role?role=${role}`, {
    method: "PATCH",
  });
  if (!res.ok) await extractErrorMessage(res, "Failed to update role");
}
