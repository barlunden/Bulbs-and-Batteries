-- =============================================================================
-- FIX: household_members infinite recursion
-- Problem: Policies prøver å lese household_members for å validere tilgang
--          Dette skapar infinite recursion: SELECT → SELECT → SELECT...
-- Løysing: DISABLE RLS på household_members
--          Sikkerheit handterast i middleware (householdId-sjekk)
-- =============================================================================

-- Fjern alle policies
DROP POLICY IF EXISTS "Medlemmer kan se andre i same husstand" ON household_members;
DROP POLICY IF EXISTS "Authenticated kan legge til medlemmer" ON household_members;
DROP POLICY IF EXISTS "Admins kan legge til medlemmer" ON household_members;
DROP POLICY IF EXISTS "Admins kan oppdatere rollar" ON household_members;
DROP POLICY IF EXISTS "Admins kan fjerne medlemmer" ON household_members;

-- DISABLE RLS på household_members
-- Sikkerheit: Middleware validerer householdId, så brukarar kan kun aksessere
-- husstandar dei er medlem av. household_members er ein join-tabell som
-- middleware brukar for validering, så den treng ikkje eigen RLS.
ALTER TABLE household_members DISABLE ROW LEVEL SECURITY;

-- Verifiser
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'household_members';
