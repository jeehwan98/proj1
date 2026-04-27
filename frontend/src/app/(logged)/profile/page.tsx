"use client";

import { useEffect, useState } from "react";
import { getMe, type UserProfile } from "@/lib/api/user";
import AccountInfoCard from "@/components/profile/AccountInfoCard";
import EditNameCard from "@/components/profile/EditNameCard";
import ChangePasswordCard from "@/components/profile/ChangePasswordCard";
import DeleteAccountCard from "@/components/profile/DeleteAccountCard";

export default function ProfilePage() {
  const [profile, setProfile] = useState<UserProfile | null>(null);

  useEffect(() => {
    getMe().then(setProfile);
  }, []);

  if (!profile) return null;

  return (
    <div className="max-w-lg space-y-6">
      <div>
        <h1 className="text-2xl font-semibold text-ink">Profile</h1>
        <p className="text-sm text-ink-light mt-1">Manage your account settings</p>
      </div>

      <AccountInfoCard profile={profile} />
      <EditNameCard savedName={profile.name} />
      {profile.provider === "LOCAL" && <ChangePasswordCard />}
      <DeleteAccountCard />
    </div>
  );
}
