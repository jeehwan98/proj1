"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { getMe } from "@/lib/api/user";
import { getUsers, adminUpdateName, adminUpdateRole, type PageResponse } from "@/lib/api/admin";
import type { UserProfile } from "@/lib/api/user";

const ROLES = ["USER", "ADMIN"];

interface RowEdit {
  name: string;
  role: string;
}

export default function AdminPage() {
  const router = useRouter();
  const [page, setPage] = useState<PageResponse<UserProfile> | null>(null);
  const [currentPage, setCurrentPage] = useState(0);
  const [edits, setEdits] = useState<Record<number, RowEdit>>({});
  const [saving, setSaving] = useState<Record<number, boolean>>({});
  const [errors, setErrors] = useState<Record<number, string>>({});

  useEffect(() => {
    getMe().then((me) => {
      if (me.role !== "ADMIN") router.replace("/");
    });
  }, [router]);

  useEffect(() => {
    getUsers(currentPage).then((data) => {
      setPage(data);
      const initial: Record<number, RowEdit> = {};
      data.content.forEach((u) => { initial[u.id] = { name: u.name, role: u.role }; });
      setEdits(initial);
    });
  }, [currentPage]);

  const isDirty = (user: UserProfile) =>
    edits[user.id]?.name !== user.name || edits[user.id]?.role !== user.role;

  const handleSave = async (user: UserProfile) => {
    const edit = edits[user.id];
    setSaving((s) => ({ ...s, [user.id]: true }));
    setErrors((e) => ({ ...e, [user.id]: "" }));
    try {
      if (edit.name !== user.name) await adminUpdateName(user.id, edit.name);
      if (edit.role !== user.role) await adminUpdateRole(user.id, edit.role);
      setPage((prev) =>
        prev ? {
          ...prev,
          content: prev.content.map((u) =>
            u.id === user.id ? { ...u, name: edit.name, role: edit.role } : u
          ),
        } : prev
      );
    } catch (err) {
      setErrors((e) => ({ ...e, [user.id]: err instanceof Error ? err.message : "Failed to save" }));
    } finally {
      setSaving((s) => ({ ...s, [user.id]: false }));
    }
  };

  if (!page) return null;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-ink">Users</h1>
        <p className="text-sm text-ink-light mt-1">{page.totalElements} registered users</p>
      </div>

      <div className="bg-surface border border-line-strong rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-line-strong text-ink-faint text-xs uppercase tracking-wide">
              <th className="text-left px-6 py-3 font-medium">Name</th>
              <th className="text-left px-6 py-3 font-medium">Email</th>
              <th className="text-left px-6 py-3 font-medium">Provider</th>
              <th className="text-left px-6 py-3 font-medium">Role</th>
              <th className="px-6 py-3" />
            </tr>
          </thead>
          <tbody>
            {page.content.map((user) => (
              <tr key={user.id} className="border-b border-line last:border-0">
                <td className="px-6 py-3">
                  <input
                    type="text"
                    value={edits[user.id]?.name ?? user.name}
                    onChange={(e) => setEdits((prev) => ({ ...prev, [user.id]: { ...prev[user.id], name: e.target.value } }))}
                    className="w-full bg-transparent border-b border-transparent hover:border-line-input focus:border-accent focus:outline-none text-ink py-0.5 transition-colors"
                  />
                </td>
                <td className="px-6 py-3 text-ink-light">{user.email}</td>
                <td className="px-6 py-3">
                  <span className="capitalize text-ink-light">{user.provider.toLowerCase()}</span>
                </td>
                <td className="px-6 py-3">
                  <select
                    value={edits[user.id]?.role ?? user.role}
                    onChange={(e) => setEdits((prev) => ({ ...prev, [user.id]: { ...prev[user.id], role: e.target.value } }))}
                    className="bg-transparent text-ink border border-line-input rounded-md px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-ring"
                  >
                    {ROLES.map((r) => <option key={r} value={r}>{r}</option>)}
                  </select>
                </td>
                <td className="px-6 py-3 text-right">
                  {errors[user.id] && <span className="text-xs text-red-500 mr-3">{errors[user.id]}</span>}
                  {isDirty(user) && (
                    <button
                      onClick={() => handleSave(user)}
                      disabled={saving[user.id]}
                      className="text-xs font-medium text-accent hover:underline disabled:opacity-50"
                    >
                      {saving[user.id] ? "Saving..." : "Save"}
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {page.totalPages > 1 && (
        <div className="flex items-center justify-between text-sm text-ink-light">
          <button
            onClick={() => setCurrentPage((p) => p - 1)}
            disabled={currentPage === 0}
            className="hover:text-ink disabled:opacity-40 transition-colors"
          >
            Previous
          </button>
          <span>Page {currentPage + 1} of {page.totalPages}</span>
          <button
            onClick={() => setCurrentPage((p) => p + 1)}
            disabled={currentPage >= page.totalPages - 1}
            className="hover:text-ink disabled:opacity-40 transition-colors"
          >
            Next
          </button>
        </div>
      )}
    </div>
  );
}
