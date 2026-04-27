"use client";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080/api";

export default function SignOutButton() {
  async function handleSignout() {
    await fetch(`${API_URL}/auth/logout`, {
      method: "POST",
      credentials: "include",
    });
    window.location.href = "/login";
  }

  return (
    <button
      onClick={handleSignout}
      className="text-xs text-ink-faint hover:text-ink-mid border border-line-strong hover:border-line-input rounded-md px-3 py-1.5 transition-colors cursor-pointer"
    >
      Sign out
    </button>
  );
}
