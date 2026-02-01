-- =============================================================================
-- FIX: households INSERT policy
-- Sjekk om policyen eksisterer og fikse den om nødvendig
-- =============================================================================

-- Sjekk eksisterande policies
SELECT tablename, policyname, cmd, with_check
FROM pg_policies
WHERE tablename = 'households';

-- Slett og opprett på nytt for å vere sikker
DROP POLICY IF EXISTS "Brukere kan opprette husstandar" ON households;

CREATE POLICY "Brukere kan opprette husstandar"
  ON households FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Verifiser
SELECT tablename, policyname, cmd, with_check
FROM pg_policies
WHERE tablename = 'households' AND cmd = 'INSERT';
