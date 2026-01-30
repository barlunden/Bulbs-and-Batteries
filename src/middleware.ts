import { defineMiddleware } from "astro:middleware";
import { supabase } from "./lib/supabase";

export const onRequest = defineMiddleware(async ({ cookies, url, redirect, locals }, next) => {
  // 1. Definer opne stiar
  const publicPaths = ["/login", "/api/auth/signin", "/api/auth/callback"];
  const isPublicPath = publicPaths.some(path => url.pathname.startsWith(path));

  if (isPublicPath) {
    return next();
  }

  // 2. Sjekk Auth
  const accessToken = cookies.get("sb-access-token")?.value;
  const refreshToken = cookies.get("sb-refresh-token")?.value;

  if (!accessToken || !refreshToken) {
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

  // 4. Sjekk om Vidar har vald eit hus
  const activeHouseholdId = cookies.get("active_household_id")?.value;
  
  // Viss han er logga inn, men ikkje har vald hus (og ikkje er på veg til å velje eitt)
  if (!activeHouseholdId && url.pathname !== "/vel-hus") {
    return redirect("/vel-hus");
  }

  locals.householdId = activeHouseholdId || null;

  return next();
});