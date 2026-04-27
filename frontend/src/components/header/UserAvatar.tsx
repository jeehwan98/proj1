import Link from "next/link";

export default function UserAvatar({ name }: { name: string }) {
  return (
    <Link href="/profile" className="flex items-center gap-2.5 hover:opacity-80 transition-opacity">
      <div className="w-7 h-7 rounded-full bg-accent flex items-center justify-center text-accent-fg text-xs font-semibold">
        {name[0].toUpperCase()}
      </div>
      <p className="text-sm font-medium text-ink">{name}</p>
    </Link>
  );
}
