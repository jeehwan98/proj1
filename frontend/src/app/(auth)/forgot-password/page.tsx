"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import AuthCard from "@/components/auth/AuthCard";
import FormField from "@/components/auth/FormField";
import FormError from "@/components/auth/FormError";
import SubmitButton from "@/components/auth/SubmitButton";
import { forgotPassword, resetPassword } from "@/lib/api/auth";

export default function ForgotPasswordPage() {
  const router = useRouter();
  const [step, setStep] = useState<"email" | "reset">("email");
  const [email, setEmail] = useState<string>("");
  const [code, setCode] = useState<string>("");
  const [newPassword, setNewPassword] = useState<string>("");
  const [confirmPassword, setConfirmPassword] = useState<string>("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(false);

  const handleEmailSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await forgotPassword(email);
      setStep("reset");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setLoading(false);
    }
  };

  const handleResetSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    if (newPassword !== confirmPassword) return setError("Passwords do not match");
    if (newPassword.length < 8) return setError("Password must be at least 8 characters");
    setLoading(true);
    try {
      await resetPassword(email, code, newPassword);
      router.push("/login");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong");
    } finally {
      setLoading(false);
    }
  };

  if (step === "email") {
    return (
      <AuthCard
        title="Forgot password"
        subtitle="Enter your email and we'll send you a reset code"
        footer={<Link href="/login" className="text-accent hover:underline">Back to sign in</Link>}
      >
        <form onSubmit={handleEmailSubmit} className="space-y-4">
          <FormField label="Email" type="email" value={email} onChange={setEmail} placeholder="you@example.com" required />
          <FormError error={error} />
          <SubmitButton loading={loading} label="Send reset code" loadingLabel="Sending..." />
        </form>
      </AuthCard>
    );
  }

  return (
    <AuthCard
      title="Reset password"
      subtitle={`Enter the code sent to ${email}`}
      footer={
        <button onClick={() => { setStep("email"); setError(null); }} className="text-accent hover:underline">
          Use a different email
        </button>
      }
    >
      <form onSubmit={handleResetSubmit} className="space-y-4">
        <FormField label="Code" type="text" value={code} onChange={setCode} placeholder="000000" required />
        <FormField label="New password" type="password" value={newPassword} onChange={setNewPassword} placeholder="••••••••" required />
        <FormField label="Confirm password" type="password" value={confirmPassword} onChange={setConfirmPassword} placeholder="••••••••" required />
        <FormError error={error} />
        <SubmitButton loading={loading} label="Reset password" loadingLabel="Resetting..." />
      </form>
    </AuthCard>
  );
}
