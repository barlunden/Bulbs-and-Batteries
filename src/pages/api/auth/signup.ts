// src/pages/api/auth/signup.ts
import type { APIRoute } from "astro";
import { supabase } from "../../../lib/supabase";

export const POST: APIRoute = async ({ request, redirect }) => {
  const formData = await request.formData();
  const email = formData.get("email")?.toString();
  const password = formData.get("password")?.toString();

  if (!email || !password) {
    return redirect("/login?error=missing_fields");
  }

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  });

  if (error) {
    return redirect(`/login?error=${encodeURIComponent(error.message)}`);
  }

  // Sjekk om Supabase krev e-post-bekreftelse
  if (data.user && !data.session) {
    return redirect("/login?message=Sjekk+e-posten+din+for+å+bekrefte+kontoen");
  }

  // Viss brukaren får session med ein gong (email confirmation er av)
  if (data.session) {
    return redirect("/login?message=Konto+oppretta!+Logg+inn+no");
  }

  return redirect("/login");
};
