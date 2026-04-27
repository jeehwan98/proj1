import Link from "next/link";
import AuthCard from "@/components/auth/AuthCard";
import RegisterForm from "@/components/auth/forms/RegisterForm";

export default function RegisterPage() {
  return (
    <AuthCard
      title="Create an account"
      subtitle="Get started for free"
      footer={
        <>
          Already have an account?{" "}
          <Link href="/login" className="text-ink font-medium hover:underline">
            Sign in
          </Link>
        </>
      }
    >
      <RegisterForm />
    </AuthCard>
  );
}
