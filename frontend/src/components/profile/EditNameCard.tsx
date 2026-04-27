"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Pencil } from "lucide-react";
import FormField from "@/components/auth/FormField";
import FormError from "@/components/auth/FormError";
import SubmitButton from "@/components/auth/SubmitButton";
import { updateName } from "@/lib/api/user";

export default function EditNameCard({ savedName }: { savedName: string }) {
  const router = useRouter();
  const [name, setName] = useState<string>(savedName);
  const [editing, setEditing] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<boolean>(false);
  const [loading, setLoading] = useState<boolean>(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(false);
    if (!name.trim()) return setError("Name cannot be empty");
    setLoading(true);
    try {
      await updateName(name.trim());
      setSuccess(true);
      setEditing(false);
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update name");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-surface border border-line-strong rounded-2xl p-6">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-sm font-semibold text-ink">Display name</h2>
        <button
          type="button"
          onClick={() => {
            if (editing) { setName(savedName); setError(null); }
            setEditing(!editing);
          }}
          className={`transition-colors ${editing ? "text-accent" : "text-ink-faint hover:text-ink"}`}
        >
          <Pencil size={14} />
        </button>
      </div>
      <form onSubmit={handleSubmit} className="space-y-4">
        <FormField label="Name" type="text" value={name} onChange={setName} required disabled={!editing} />
        {error && <FormError error={error} />}
        {success && <p className="text-sm text-green-600">Name updated successfully.</p>}
        {editing && (
          <SubmitButton loading={loading} label="Save" loadingLabel="Saving..." disabled={name.trim() === savedName} />
        )}
      </form>
    </div>
  );
}
