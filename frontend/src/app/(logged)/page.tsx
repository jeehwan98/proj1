import { getAuthPayload } from "@/lib/auth";

export default async function HomePage() {
  const payload = await getAuthPayload();

  return (
    <div>
      <h1 className="text-2xl font-semibold text-ink mb-1">
        Welcome back{payload?.name ? `, ${payload.name}` : ""}
      </h1>
      <p className="text-sm text-ink-light">You&apos;re signed in.</p>
    </div>
  );
}
