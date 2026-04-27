import Header from "@/components/header/Header";
import { getAuthPayload } from "@/lib/auth";

export default async function DashboardLayout({ children }: { children: React.ReactNode }) {
  const payload = await getAuthPayload();
  console.log("payload: ", payload);

  return (
    <div className="min-h-screen bg-page">
      <Header name={payload?.name} role={payload?.role} />
      <main className="max-w-4xl mx-auto px-6 py-8">
        {children}
      </main>
    </div>
  );
}
