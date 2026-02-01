import { defineMiddleware } from "astro:middleware";
import { supabase, createAuthenticatedClient } from "./lib/supabase";

export const onRequest = defineMiddleware(async ({ cookies, url, redirect, locals }, next) => {
  // 1. Definer opne stiar
  const authPaths = ["/login", "/api/auth/signin", "/api/auth/signup", "/api/auth/signout", "/api/auth/callback"];
  const isAuthPath = authPaths.some(path => url.pathname.startsWith(path));

  if (isAuthPath) {
    return next();
  }

  // 2. Sjekk Auth
  const accessToken = cookies.get("sb-access-token")?.value;
  const refreshToken = cookies.get("sb-refresh-token")?.value;

  console.log("🔍 Middleware - checking auth:", { 
    hasAccessToken: !!accessToken, 
    hasRefreshToken: !!refreshToken,
    path: url.pathname 
  });

  if (!accessToken || !refreshToken) {
    console.log("❌ No tokens found, redirecting to /login");
    return redirect("/login");
  }

  const { data, error } = await supabase.auth.setSession({
    access_token: accessToken,
    refresh_token: refreshToken,
  });

  if (error || !data.user) {
    cookies.delete("sb-access-token", { path: "/" });
    cookies.delete("sb-refresh-token", { path: "/" });
    return redirect("/login");
  }

  // 3. Set Brukar i locals
  locals.user = data.user;

  // 4. Viss brukaren prøver å gå til /vel-hus, slepp dei igjennom (dei har alt auth)
  if (url.pathname.startsWith("/vel-hus")) {
    return next();
  }

  // 4. Sjekk om Vidar har vald eit hus
  const activeHouseholdId = cookies.get("active_household_id")?.value;
  
  // Viss han er logga inn, men ikkje har vald hus, send til /vel-hus
  if (!activeHouseholdId) {
    return redirect("/vel-hus");
  }

  // 5. Valider at brukaren faktisk har tilgang til det valde huset (SIKKERHEIT)
  // Bruk autentisert klient for å unngå RLS-blokkering
  const authedSupabase = createAuthenticatedClient(accessToken);
  const { data: membership, error: membershipError } = await authedSupabase
    .from("household_members")
    .select("household_id")
    .eq("user_id", data.user.id)
    .eq("household_id", activeHouseholdId)
    .single();

  if (membershipError || !membership) {
    // Brukaren prøvde å få tilgang til eit hus dei ikkje er medlem av
    console.error("Medlemskapvalidering feila:", membershipError);
    cookies.delete("active_household_id", { path: "/" });
    return redirect("/vel-hus");
  }

  locals.householdId = activeHouseholdId;

  return next();
});