// src/pages/api/auth/signin.ts
import type { APIRoute } from "astro";
import { supabase } from "../../../lib/supabase";

export const POST: APIRoute = async ({ request, cookies, redirect }) => {
  const formData = await request.formData();
  const email = formData.get("email")?.toString();
  const password = formData.get("password")?.toString(); // Nytt felt!

  if (!email || !password) {
    return redirect("/login?error=missing_fields");
  }

  // Her brukar vi "password" i staden for "OTP"
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    return redirect(`/login?error=${encodeURIComponent(error.message)}`);
  }

  if (data.session) {
    const isProduction = import.meta.env.PROD;
    cookies.set("sb-access-token", data.session.access_token, { 
      path: "/", 
      sameSite: "lax", 
      secure: isProduction,
      httpOnly: true 
    });
    cookies.set("sb-refresh-token", data.session.refresh_token, { 
      path: "/", 
      sameSite: "lax", 
      secure: isProduction,
      httpOnly: true 
    });
    return redirect("/");
  }

  return redirect("/login");
};