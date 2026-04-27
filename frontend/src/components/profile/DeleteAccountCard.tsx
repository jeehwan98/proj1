"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import FormError from "@/components/auth/FormError";
import { deleteAccount } from "@/lib/api/user";

export default function DeleteAccountCard() {
  const router = useRouter();
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleDelete = async () => {
    if (!confirm("Are you sure you want to delete your account? This cannot be undone.")) return;
    setLoading(true);
    setError(null);
    try {
      await deleteAccount();
      router.push("/login");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to delete account");
      setLoading(false);
    }
  };

  return (
    <div className="bg-surface border border-red-200 dark:border-red-900 rounded-2xl p-6">
      <h2 className="text-sm font-semibold text-red-600 mb-2 flex justify-center">Delete account</h2>
      <p className="text-sm text-ink-light mb-4 flex justify-center">
        This will permanently delete your account and all your data.
      </p>
      {error && <FormError error={error} />}
      <div className="flex justify-center">
        <button
          onClick={handleDelete}
          disabled={loading}
          className="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 disabled:opacity-50 rounded-lg transition-colors"
        >
          {loading ? "Deleting..." : "Delete account"}
        </button>
      </div>
    </div>
  );
}
