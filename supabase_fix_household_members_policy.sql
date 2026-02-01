-- =============================================================================
-- FIX: household_members INSERT policy
-- Problemet: Policyen sjekkar household_id mot seg sjølv i staden for den nye raden
-- =============================================================================

-- Slett den feilaktige policyen
DROP POLICY IF EXISTS "Admins kan legge til medlemmer" ON household_members;

-- Opprett ny korrekt policy
-- Tillat INSERT viss:
-- 1) Du er admin i husstanden DU prøver å legge til medlem i
-- 2) ELLER husstanden har ingen admin ennå (første brukar)
CREATE POLICY "Admins kan legge til medlemmer"
  ON household_members FOR INSERT
  TO authenticated
  WITH CHECK (
    -- Er du admin i denne husstanden?
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    -- ELLER: Har denne husstanden ingen admin ennå?
    NOT EXISTS (
      SELECT 1 
      FROM household_members hm
      WHERE hm.household_id = household_members.household_id 
        AND hm.role = 'admin'
    )
  );

-- Verifiser at policyen er oppretta riktig
SELECT 
  policyname,
  cmd,
  with_check
FROM pg_policies
WHERE tablename = 'household_members' 
  AND policyname = 'Admins kan legge til medlemmer';
