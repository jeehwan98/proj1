"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import FormField from "../FormField";
import FormError from "../FormError";
import SubmitButton from "../SubmitButton";
import { loginUser } from "@/lib/api/auth";
import OAuthButtons from "@/components/auth/OAuthButtons";

export default function LoginForm() {
  const router = useRouter();
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState<boolean>(false);

  const handleSubmit = async (e: React.SyntheticEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      await loginUser(email, password);
      router.push("/");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-4">
      <form onSubmit={handleSubmit} className="space-y-4">
        <FormField
          label="Email"
          type="email"
          value={email}
          onChange={setEmail}
          placeholder="you@example.com"
          required
        />
        <div>
          <FormField
            label="Password"
            type="password"
            value={password}
            onChange={setPassword}
            placeholder="••••••••"
            required
          />
          <div className="text-right mt-1">
            <Link href="/forgot-password" className="text-xs text-ink-faint hover:text-ink transition-colors">
              Forgot password?
            </Link>
          </div>
        </div>
        <FormError error={error} />
        <SubmitButton
          loading={loading}
          label="Sign in"
          loadingLabel="Signing in..."
        />
      </form>
      <OAuthButtons />
    </div>
  );
}
