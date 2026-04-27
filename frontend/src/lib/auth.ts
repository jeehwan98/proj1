import { cookies } from "next/headers";
import { decodeJwtPayload } from "@/lib/jwt";

export async function getAuthPayload() {
  const cookieStore = await cookies();
  const token = cookieStore.get("auth-token")?.value;
  return token ? decodeJwtPayload(token) : null;
}
