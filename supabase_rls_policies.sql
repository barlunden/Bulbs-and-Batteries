-- =============================================================================
-- SUPABASE ROW LEVEL SECURITY (RLS) POLICIES
-- Bulbs & Batteries - Komplett RLS-oppsett for alle tabellar
-- =============================================================================

-- =============================================================================
-- 1. PROFILES (Brukarprofiler)
-- =============================================================================

-- Aktiver RLS (viss ikkje allerede aktivert)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Slett eksisterande policies (for rerun)
DROP POLICY IF EXISTS "Profiles er synlige for alle autentiserte brukere" ON profiles;
DROP POLICY IF EXISTS "Brukere kan oppdatere sin egen profil" ON profiles;

-- SELECT: Alle autentiserte brukarar kan sjå alle profiler
-- Dette er nødvendig for invitasjonsfunksjonalitet (søke etter e-post)
CREATE POLICY "Profiles er synlige for alle autentiserte brukere"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

-- UPDATE: Brukarar kan kun oppdatere sin eigen profil
CREATE POLICY "Brukere kan oppdatere sin egen profil"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- INSERT: Skal skje via trigger, ikkje manuelt
-- Ingen INSERT-policy trengs


-- =============================================================================
-- 2. HOUSEHOLDS (Husstandar/Organisasjonar)
-- =============================================================================

ALTER TABLE households ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Brukere kan se husstandar dei er medlem av" ON households;
DROP POLICY IF EXISTS "Brukere kan opprette husstandar" ON households;
DROP POLICY IF EXISTS "Admins kan oppdatere husstandar" ON households;
DROP POLICY IF EXISTS "Admins kan slette husstandar" ON households;

-- SELECT: Kan kun sjå husstandar der du er medlem
CREATE POLICY "Brukere kan se husstandar dei er medlem av"
  ON households FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- INSERT: Alle kan opprette ny husstand
CREATE POLICY "Brukere kan opprette husstandar"
  ON households FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- UPDATE: Kun admins kan oppdatere husstand (name, type, global_note)
CREATE POLICY "Admins kan oppdatere husstandar"
  ON households FOR UPDATE
  TO authenticated
  USING (
    id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- DELETE: Kun admins kan slette husstand (valgfritt - kan kommenteres ut viss du ikkje vil tillate sletting)
CREATE POLICY "Admins kan slette husstandar"
  ON households FOR DELETE
  TO authenticated
  USING (
    id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );


-- =============================================================================
-- 3. HOUSEHOLD_MEMBERS (Knyting mellom brukarar og husstandar)
-- =============================================================================

ALTER TABLE household_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Medlemmer kan se andre i same husstand" ON household_members;
DROP POLICY IF EXISTS "Admins kan legge til medlemmer" ON household_members;
DROP POLICY IF EXISTS "Admins kan oppdatere rollar" ON household_members;
DROP POLICY IF EXISTS "Admins kan fjerne medlemmer" ON household_members;
DROP POLICY IF EXISTS "Brukere kan opprette sin første admin-tilgang" ON household_members;

-- SELECT: Kan sjå medlemmer i husstandar du er medlem av
CREATE POLICY "Medlemmer kan se andre i same husstand"
  ON household_members FOR SELECT
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- INSERT: Kun admins kan legge til nye medlemmer
-- PLUSS: Brukaren kan legge seg til som første admin i ny husstand
CREATE POLICY "Admins kan legge til medlemmer"
  ON household_members FOR INSERT
  TO authenticated
  WITH CHECK (
    -- Tillat insert viss du er admin i denne husstanden
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    OR
    -- ELLER: Tillat viss husstanden ikkje har nokon admin ennå (første bruker)
    NOT EXISTS (
      SELECT 1 
      FROM household_members 
      WHERE household_id = household_members.household_id AND role = 'admin'
    )
  );

-- UPDATE: Kun admins kan endre rollar
CREATE POLICY "Admins kan oppdatere rollar"
  ON household_members FOR UPDATE
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

-- DELETE: Kun admins kan fjerne medlemmer (men ikkje seg sjølv)
CREATE POLICY "Admins kan fjerne medlemmer"
  ON household_members FOR DELETE
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid() AND role = 'admin'
    )
    AND user_id != auth.uid() -- Kan ikkje slette seg sjølv
  );


-- =============================================================================
-- 4. ITEMS (Registrert utstyr)
-- =============================================================================

ALTER TABLE items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Medlemmer kan se items i sin husstand" ON items;
DROP POLICY IF EXISTS "Medlemmer kan opprette items" ON items;
DROP POLICY IF EXISTS "Medlemmer kan oppdatere items" ON items;
DROP POLICY IF EXISTS "Medlemmer kan slette items" ON items;

-- SELECT: Kun items frå husstandar du er medlem av
CREATE POLICY "Medlemmer kan se items i sin husstand"
  ON items FOR SELECT
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- INSERT: Alle medlemmer kan legge til utstyr
CREATE POLICY "Medlemmer kan opprette items"
  ON items FOR INSERT
  TO authenticated
  WITH CHECK (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- UPDATE: Alle medlemmer kan oppdatere utstyr (inkl. last_replaced)
CREATE POLICY "Medlemmer kan oppdatere items"
  ON items FOR UPDATE
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- DELETE: Alle medlemmer kan slette utstyr
CREATE POLICY "Medlemmer kan slette items"
  ON items FOR DELETE
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );


-- =============================================================================
-- 5. STOCK (Lagerbeholdning)
-- =============================================================================

ALTER TABLE stock ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Medlemmer kan se stock i sin husstand" ON stock;
DROP POLICY IF EXISTS "Medlemmer kan opprette stock" ON stock;
DROP POLICY IF EXISTS "Medlemmer kan oppdatere stock" ON stock;
DROP POLICY IF EXISTS "Medlemmer kan slette stock" ON stock;

-- SELECT: Kun stock frå husstandar du er medlem av
CREATE POLICY "Medlemmer kan se stock i sin husstand"
  ON stock FOR SELECT
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- INSERT: Alle medlemmer kan registrere innkjøp
CREATE POLICY "Medlemmer kan opprette stock"
  ON stock FOR INSERT
  TO authenticated
  WITH CHECK (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- UPDATE: Alle medlemmer kan justere stock (current_count, min_threshold)
CREATE POLICY "Medlemmer kan oppdatere stock"
  ON stock FOR UPDATE
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );

-- DELETE: Alle medlemmer kan slette stock-linjer
CREATE POLICY "Medlemmer kan slette stock"
  ON stock FOR DELETE
  TO authenticated
  USING (
    household_id IN (
      SELECT household_id 
      FROM household_members 
      WHERE user_id = auth.uid()
    )
  );


-- =============================================================================
-- 6. GENERAL_NOTES (Generelle notat - viss du har denne tabellen)
-- =============================================================================
-- MERK: Denne tabellen kan være overflødig siden du bruker households.global_note
-- Men om du har den som eiga tabell:

-- Sjekk om tabellen eksisterer først
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'general_notes') THEN
    ALTER TABLE general_notes ENABLE ROW LEVEL SECURITY;

    DROP POLICY IF EXISTS "Medlemmer kan se notat i sin husstand" ON general_notes;
    DROP POLICY IF EXISTS "Medlemmer kan opprette notat" ON general_notes;
    DROP POLICY IF EXISTS "Medlemmer kan oppdatere notat" ON general_notes;
    DROP POLICY IF EXISTS "Medlemmer kan slette notat" ON general_notes;

    -- SELECT
    EXECUTE 'CREATE POLICY "Medlemmer kan se notat i sin husstand"
      ON general_notes FOR SELECT
      TO authenticated
      USING (
        household_id IN (
          SELECT household_id 
          FROM household_members 
          WHERE user_id = auth.uid()
        )
      )';

    -- INSERT
    EXECUTE 'CREATE POLICY "Medlemmer kan opprette notat"
      ON general_notes FOR INSERT
      TO authenticated
      WITH CHECK (
        household_id IN (
          SELECT household_id 
          FROM household_members 
          WHERE user_id = auth.uid()
        )
      )';

    -- UPDATE
    EXECUTE 'CREATE POLICY "Medlemmer kan oppdatere notat"
      ON general_notes FOR UPDATE
      TO authenticated
      USING (
        household_id IN (
          SELECT household_id 
          FROM household_members 
          WHERE user_id = auth.uid()
        )
      )';

    -- DELETE
    EXECUTE 'CREATE POLICY "Medlemmer kan slette notat"
      ON general_notes FOR DELETE
      TO authenticated
      USING (
        household_id IN (
          SELECT household_id 
          FROM household_members 
          WHERE user_id = auth.uid()
        )
      )';
  END IF;
END $$;


-- =============================================================================
-- VERIFIKASJON
-- =============================================================================
-- Køyr denne for å sjekke at alle policies er på plass:

SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Sjekk at RLS er aktivert på alle tabellar:
SELECT 
  tablename, 
  rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'households', 'household_members', 'items', 'stock', 'general_notes');
