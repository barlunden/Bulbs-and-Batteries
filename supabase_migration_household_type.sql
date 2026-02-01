-- Legg til household type (home vs facility)
-- Køyr denne i Supabase SQL Editor

-- Legg til type-kolonne
ALTER TABLE households 
ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'home' CHECK (type IN ('home', 'facility'));

-- Oppdater eksisterande husstander til 'home' som standard
UPDATE households SET type = 'home' WHERE type IS NULL;

-- Kommentar for dokumentasjon
COMMENT ON COLUMN households.type IS 'home = vanleg husstand, facility = skule/burettslag/kjøpesenter';
