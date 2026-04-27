import Link from "next/link";
import UserAvatar from "./UserAvatar";
import SignOutButton from "./SignOutButton";
import ThemeToggle from "./ThemeToggle";

export default function Header({ name, role }: { name?: string; role?: string }) {
  return (
    <header className="bg-surface border-b border-line px-8 h-14 flex items-center justify-between">
      <Link href="/" className="text-sm font-semibold text-ink tracking-tight">
        Authentication24
      </Link>

      <div className="flex items-center gap-4">
        {role === "ADMIN" && (
          <Link href="/admin" className="text-xs font-medium text-ink-faint hover:text-ink transition-colors">
            Admin
          </Link>
        )}
        {name && (
          <>
            <UserAvatar name={name} />
            <div className="w-px h-4 bg-line-strong" />
          </>
        )}
        <ThemeToggle />
        <SignOutButton />
      </div>
    </header>
  );
}
