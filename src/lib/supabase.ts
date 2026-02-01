import { createClient } from '@supabase/supabase-js'

// Global klient for auth-operasjonar (middleware, auth callbacks)
export const supabase = createClient(
  import.meta.env.SUPABASE_URL,
  import.meta.env.SUPABASE_ANON_KEY,
  {
    auth: {
      flowType: 'implicit',
      persistSession: false,
      detectSessionInUrl: false,
      autoRefreshToken: false
    }
  }
)

// Service role klient for operasjonar som må omgå RLS
// (første admin-insert, make_me_admin, etc.)
export const supabaseAdmin = createClient(
  import.meta.env.SUPABASE_URL,
  import.meta.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false
    }
  }
)

// Lag ein Supabase-klient med brukar-spesifikk access token (per request)
// Dette forhindrar at sessionar blir blanda på server-side
export function createAuthenticatedClient(accessToken: string) {
  return createClient(
    import.meta.env.SUPABASE_URL,
    import.meta.env.SUPABASE_ANON_KEY,
    {
      global: {
        headers: {
          Authorization: `Bearer ${accessToken}`
        }
      },
      auth: {
        persistSession: false
      }
    }
  )
}