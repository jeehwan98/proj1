import type { ReactNode } from "react";

interface AuthCardProps {
  title: string;
  subtitle: string;
  footer: ReactNode;
  children: ReactNode;
}

export default function AuthCard({ title, subtitle, footer, children }: AuthCardProps) {
  return (
    <div className="w-full max-w-sm bg-surface rounded-2xl shadow-sm border border-line-strong p-8">
      <h1 className="text-2xl font-semibold text-ink mb-1">{title}</h1>
      <p className="text-sm text-ink-light mb-6">{subtitle}</p>
      {children}
      <div className="text-sm text-ink-light text-center mt-6">{footer}</div>
    </div>
  );
}
