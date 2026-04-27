"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import FormField from "../FormField";
import FormError from "../FormError";
import SubmitButton from "../SubmitButton";
import { registerUser, verifyUser } from "@/lib/api/auth";
import { toast } from "sonner";
import OAuthButtons from "@/components/auth/OAuthButtons";

export default function RegisterForm() {
  const router = useRouter();
  const [step, setStep] = useState<"credentials" | "verify">("credentials");
  const [name, setName] = useState<string>("");
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [code, setCode] = useState<string>("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(false);

  const handleCredentials = async (e: React.SyntheticEvent) => {
    e.preventDefault();
    setError(null);

    if (name.trim().length === 0) return setError("Name is required");
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return setError("Invalid email format");
    if (password.length < 8) return setError("Password must be at least 8 characters");

    setLoading(true);
    try {
      await registerUser(name, email, password);
      setStep("verify");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async (e: React.SyntheticEvent) => {
    e.preventDefault();
    setError(null);

    if (code.trim().length !== 6) return setError("Enter the 6-digit code sent to your email");

    setLoading(true);
    try {
      await verifyUser(email, code);
      toast.success("Email verified! You can now sign in.");
      router.push("/login");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Verification failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  if (step === "verify") {
    return (
      <form onSubmit={handleVerify} className="space-y-4">
        <p className="text-sm text-ink-light">
          A 6-digit code was sent to <span className="font-medium text-ink">{email}</span>.
        </p>
        <FormField
          label="Verification code"
          type="text"
          value={code}
          onChange={setCode}
          placeholder="000000"
          required
        />
        <FormError error={error} />
        <SubmitButton
          loading={loading}
          label="Verify email"
          loadingLabel="Verifying..."
        />
        <button
          type="button"
          onClick={() => { setStep("credentials"); setError(null); setCode(""); }}
          className="w-full text-sm text-ink-light hover:text-ink transition-colors"
        >
          Go back
        </button>
      </form>
    );
  }

  return (
    <div className="space-y-4">
      <form onSubmit={handleCredentials} className="space-y-4">
        <FormField
          label="Name"
          type="text"
          value={name}
          onChange={setName}
          placeholder="Name"
          required
        />
        <FormField
          label="Email"
          type="email"
          value={email}
          onChange={setEmail}
          placeholder="email@example.com"
          required
        />
        <FormField
          label="Password"
          type="password"
          value={password}
          onChange={setPassword}
          placeholder="••••••••"
          required
        />
        <FormError error={error} />
        <SubmitButton
          loading={loading}
          label="Create account"
          loadingLabel="Sending code..."
        />
      </form>
      <OAuthButtons />
    </div>
  );
}
