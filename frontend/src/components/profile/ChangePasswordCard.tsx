"use client";

import { useState } from "react";
import FormField from "@/components/auth/FormField";
import FormError from "@/components/auth/FormError";
import SubmitButton from "@/components/auth/SubmitButton";
import { changePassword } from "@/lib/api/user";

export default function ChangePasswordCard() {
  const [currentPassword, setCurrentPassword] = useState<string>("");
  const [newPassword, setNewPassword] = useState<string>("");
  const [confirmPassword, setConfirmPassword] = useState<string>("");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<boolean>(false);
  const [loading, setLoading] = useState<boolean>(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(false);
    if (newPassword !== confirmPassword) return setError("Passwords do not match");
    if (newPassword.length < 8) return setError("Password must be at least 8 characters");
    setLoading(true);
    try {
      await changePassword(currentPassword, newPassword);
      setSuccess(true);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to change password");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-surface border border-line-strong rounded-2xl p-6">
      <h2 className="text-sm font-semibold text-ink mb-4">Change password</h2>
      <form onSubmit={handleSubmit} className="space-y-4">
        <FormField label="Current password" type="password" value={currentPassword} onChange={setCurrentPassword} required />
        <FormField label="New password" type="password" value={newPassword} onChange={setNewPassword} required />
        <FormField label="Confirm new password" type="password" value={confirmPassword} onChange={setConfirmPassword} required />
        {error && <FormError error={error} />}
        {success && <p className="text-sm text-green-600">Password changed successfully.</p>}
        <SubmitButton loading={loading} label="Change password" loadingLabel="Updating..." />
      </form>
    </div>
  );
}
