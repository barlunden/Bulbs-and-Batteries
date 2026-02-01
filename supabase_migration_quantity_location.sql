-- Legg til quantity (antall) felt på items tabellen
ALTER TABLE items ADD COLUMN IF NOT EXISTS quantity INTEGER DEFAULT 1;

-- Legg til strukturerte lokasjonsfelt
ALTER TABLE items ADD COLUMN IF NOT EXISTS building TEXT;
ALTER TABLE items ADD COLUMN IF NOT EXISTS department TEXT;
ALTER TABLE items ADD COLUMN IF NOT EXISTS detail TEXT;

-- Migrer eksisterende location-data til detail-feltet
UPDATE items SET detail = location WHERE location IS NOT NULL AND detail IS NULL;

-- Indekser for raskere søk
CREATE INDEX IF NOT EXISTS idx_items_type ON items(type);
CREATE INDEX IF NOT EXISTS idx_items_category ON items(category);
CREATE INDEX IF NOT EXISTS idx_items_building ON items(building);
CREATE INDEX IF NOT EXISTS idx_items_department ON items(department);
CREATE INDEX IF NOT EXISTS idx_items_household_category ON items(household_id, category);

-- Oppdater stock-logikken til å håndtere quantity
-- Når vi genererer stock, må vi nå multiplisere med quantity
-- (Dette håndteres i applikasjonskoden, ikke i databasen)
