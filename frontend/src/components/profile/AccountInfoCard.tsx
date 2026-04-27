import type { UserProfile } from "@/lib/api/user";

export default function AccountInfoCard({ profile }: { profile: UserProfile }) {
  return (
    <div className="bg-surface border border-line-strong rounded-2xl p-6 space-y-3">
      <h2 className="text-sm font-semibold text-ink">Account</h2>
      <div className="text-sm text-ink-light space-y-1">
        <p><span className="text-ink-mid">Email</span> — {profile.email}</p>
        <p>
          <span className="text-ink-mid">Sign-in method</span>{" "}
          — <span className="capitalize">{profile.provider.toLowerCase()}</span>
        </p>
      </div>
    </div>
  );
}
