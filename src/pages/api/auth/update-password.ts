// src/pages/api/auth/update-password.ts
import type { APIRoute } from "astro";
import { supabase } from "../../../lib/supabase";

export const POST: APIRoute = async ({ request, cookies, redirect }) => {
  const formData = await request.formData();
  const password = formData.get("password")?.toString();
  const passwordConfirm = formData.get("passwordConfirm")?.toString();

  if (!password || !passwordConfirm) {
    return redirect("/tilbakestill-passord?error=missing_fields");
  }

  if (password !== passwordConfirm) {
    return redirect("/tilbakestill-passord?error=Passorda er ikkje like");
  }

  if (password.length < 6) {
    return redirect("/tilbakestill-passord?error=Passordet må vere minst 6 teikn");
  }

  // Hent access token frå URL hash (Supabase sender dette etter reset)
  // Dette er tilgjengelig via Supabase sin session
  const accessToken = cookies.get("sb-access-token")?.value;
  
  if (!accessToken) {
    return redirect("/tilbakestill-passord?error=Ugyldig eller utløpt tilbakestillingslenke");
  }

  // Oppdater passord
  const { data, error } = await supabase.auth.updateUser({
    password: password
  });

  if (error) {
    console.error("Update password error:", error);
    return redirect(`/tilbakestill-passord?error=${encodeURIComponent(error.message)}`);
  }

  if (data.user) {
    // Set nye cookies (session er allerede oppdatert)
    console.log("✅ Password updated successfully");
    return redirect("/dashboard?message=Passordet er oppdatert");
  }

  return redirect("/tilbakestill-passord?error=Noko gjekk galt");
};
