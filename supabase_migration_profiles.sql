-- Opprett profiles-tabell for å lagre brukerinformasjon
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Legg til full_name-kolonnen hvis den ikke finnes
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'profiles' AND column_name = 'full_name'
  ) THEN
    ALTER TABLE profiles ADD COLUMN full_name TEXT;
  END IF;
END $$;

-- Aktiver RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Lag policy slik at alle kan lese profiles (for å finne brukere ved invitasjon)
CREATE POLICY "Profiles er synlige for alle autentiserte brukere"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

-- Lag policy slik at brukere kun kan oppdatere sin egen profil
CREATE POLICY "Brukere kan oppdatere sin egen profil"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Opprett en trigger-funksjon som automatisk lager profil når ny bruker registreres
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Opprett trigger som kjører når ny bruker opprettes
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Migrer eksisterende brukere til profiles
INSERT INTO profiles (id, email, full_name)
SELECT 
  id, 
  email,
  COALESCE(raw_user_meta_data->>'full_name', email) as full_name
FROM auth.users
WHERE id NOT IN (SELECT id FROM profiles)
ON CONFLICT (id) DO NOTHING;
