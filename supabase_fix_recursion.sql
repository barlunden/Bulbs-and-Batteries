-- =============================================================================
-- FIX: household_members + households infinite recursion
-- Problem: Policies prøver å lese household_members for å validere tilgang
--          Dette skapar infinite recursion: SELECT → SELECT → SELECT...
-- Løysing: DISABLE RLS på household_members OG households
--          Sikkerheit handterast i middleware (householdId-sjekk)
-- =============================================================================

-- Fjern alle household_members policies
DROP POLICY IF EXISTS "Medlemmer kan se andre i same husstand" ON household_members;
DROP POLICY IF EXISTS "Authenticated kan legge til medlemmer" ON household_members;
DROP POLICY IF EXISTS "Admins kan legge til medlemmer" ON household_members;
DROP POLICY IF EXISTS "Admins kan oppdatere rollar" ON household_members;
DROP POLICY IF EXISTS "Admins kan fjerne medlemmer" ON household_members;

-- Fjern alle households policies
DROP POLICY IF EXISTS "Brukere kan se husstandar dei er medlem av" ON households;
DROP POLICY IF EXISTS "Brukere kan opprette husstandar" ON households;
DROP POLICY IF EXISTS "Admins kan oppdatere husstandar" ON households;
DROP POLICY IF EXISTS "Admins kan slette husstandar" ON households;

-- DISABLE RLS på begge tabellar
-- Sikkerheit: Middleware validerer householdId før ALLE requests
-- Brukarar kan kun aksessere husstandar dei er medlem av
ALTER TABLE household_members DISABLE ROW LEVEL SECURITY;
ALTER TABLE households DISABLE ROW LEVEL SECURITY;

-- Items og Stock har framleis RLS for ekstra lag med sikkerheit
-- Men household_members og households er allereie beskytta av middleware

-- Verifiser
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('household_members', 'households');
