// src/pages/api/auth/callback.ts
import type { APIRoute } from "astro";
import { createClient } from '@supabase/supabase-js';

export const GET: APIRoute = async ({ url, cookies, redirect }) => {
  const code = url.searchParams.get("code");

  if (!code) return redirect("/login");

  // Vi lager en helt rå, ny klient her for å unngå gammel config-støy
  const tempSupabase = createClient(
    import.meta.env.SUPABASE_URL,
    import.meta.env.SUPABASE_ANON_KEY,
    { auth: { persistSession: false } }
  );

  const { data, error } = await tempSupabase.auth.exchangeCodeForSession(code);

  if (error) {
    console.error("Gorgon-feil detaljer:", error.message);
    // Viss dette feiler, prøver vi å sjekke om vi fekk sesjonen via hash (fallback)
    return redirect("/login?error=auth_failed");
  }

  if (data.session) {
    cookies.set("sb-access-token", data.session.access_token, { path: "/", sameSite: "lax", secure: false });
    cookies.set("sb-refresh-token", data.session.refresh_token, { path: "/", sameSite: "lax", secure: false });
    return redirect("/");
  }

  return redirect("/login");
};