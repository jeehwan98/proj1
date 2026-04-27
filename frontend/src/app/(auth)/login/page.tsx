import Link from "next/link";
import AuthCard from "@/components/auth/AuthCard";
import LoginForm from "@/components/auth/forms/LoginForm";

export default function LoginPage() {
  return (
    <AuthCard
      title="Welcome back"
      subtitle="Sign in to your account"
      footer={
        <>
          Don&apos;t have an account?{" "}
          <Link href="/register" className="text-ink font-medium hover:underline">
            Register
          </Link>
        </>
      }
    >
      <LoginForm />
    </AuthCard>
  );
}
