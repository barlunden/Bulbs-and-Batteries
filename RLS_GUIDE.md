# 🔐 Row Level Security (RLS) Oppsett

## Status: ✅ RLS er aktivert på alle tabellar

Alle tabellane har `rowsecurity = true`, så no treng du berre å opprette policies.

## Steg-for-steg

### 1. Køyr RLS Policies
1. Gå til [Supabase Dashboard](https://app.supabase.com)
2. Vel prosjektet ditt
3. Gå til **SQL Editor**
4. Opne [`supabase_rls_policies.sql`](supabase_rls_policies.sql)
5. Kopier heile innhaldet (CTRL/CMD + A, CTRL/CMD + C)
6. Lim inn i SQL Editor
7. Trykk **Run** (Cmd/Ctrl + Enter)

### 2. Verifiser at policies er oppretta

Køyr denne spørjinga i SQL Editor:

```sql
SELECT 
  tablename,
  policyname,
  cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

Du skal sjå omtrent **20 policies** fordelt på tabellane:
- **profiles**: 2 policies (SELECT, UPDATE)
- **households**: 4 policies (SELECT, INSERT, UPDATE, DELETE)
- **household_members**: 4 policies (SELECT, INSERT, UPDATE, DELETE)
- **items**: 4 policies (SELECT, INSERT, UPDATE, DELETE)
- **stock**: 4 policies (SELECT, INSERT, UPDATE, DELETE)
- **general_notes**: 4 policies (viss tabellen eksisterer)

## 🔒 Sikkerheitsreglar

### Kven har tilgang til kva?

#### **Profiles** (Brukarprofiler)
- ✅ Alle autentiserte kan **sjå** alle profiler (nødvendig for invitasjon)
- ✅ Kan kun **oppdatere** din eigen profil

#### **Households** (Husstandar)
- ✅ Kan kun **sjå** husstandar du er medlem av
- ✅ Alle kan **opprette** ny husstand
- ✅ Kun **admins** kan oppdatere/slette

#### **Household Members**
- ✅ Kan **sjå** medlemmer i same husstand
- ✅ Kun **admins** kan legge til/fjerne medlemmer
- ✅ Første brukar kan gjere seg til admin (spesialregel)

#### **Items** (Utstyr)
- ✅ Full tilgang (CRUD) for medlemmer i **eigen husstand**
- ❌ Kan **ikkje** sjå andre sine husstandar

#### **Stock** (Lagerbeholdning)
- ✅ Full tilgang (CRUD) for medlemmer i **eigen husstand**
- ❌ Kan **ikkje** sjå andre sine husstandar

## 🐛 Feilsøking

### Problem: "new row violates row-level security policy"

**Løysing:** Sjekk at:
1. Du er logga inn (`auth.uid()` finnes)
2. Du er medlem av husstanden du prøver å aksessere
3. Du har riktig rolle (admin for visse operasjonar)

### Problem: "permission denied for table"

**Løysing:** RLS er aktivert, men policies manglar. Køyr `supabase_rls_policies.sql` på nytt.

### Problem: Kan ikkje legge til første admin

**Løysing:** Dette er handtert i koden din med:
```typescript
const { data: updateData, error: updateError } = await supabase
  .from("household_members")
  .update({ role: "admin" })
  ...
```

Viss dette feiler, bruk `supabase.rpc()` med ein SECURITY DEFINER-funksjon.

## 📝 Neste steg etter RLS

Når RLS er på plass, køyr også desse migrasjonane:

1. ✅ [`supabase_migration_profiles.sql`](supabase_migration_profiles.sql) - Profiles trigger
2. ⏳ [`supabase_migration_household_type.sql`](supabase_migration_household_type.sql) - Type-kolonnen
3. ⏳ [`supabase_migration_quantity_location.sql`](supabase_migration_quantity_location.sql) - Bulk features

## 🧪 Testing

Test at RLS fungerer:

```sql
-- Test 1: Logg inn som brukar A, opprett husstand
-- Test 2: Logg inn som brukar B, prøv å sjå husstand A (skal feile)
-- Test 3: Inviter brukar B til husstand A
-- Test 4: Logg inn som brukar B, prøv å sjå husstand A (skal fungere)
```

## 📊 Ytelses-tips

RLS kan vere tregt viss du har mange medlemmar. Vurder å legge til index:

```sql
CREATE INDEX IF NOT EXISTS idx_household_members_user_id 
  ON household_members(user_id);

CREATE INDEX IF NOT EXISTS idx_household_members_household_id 
  ON household_members(household_id);

CREATE INDEX IF NOT EXISTS idx_items_household_id 
  ON items(household_id);

CREATE INDEX IF NOT EXISTS idx_stock_household_id 
  ON stock(household_id);
```

Desse er truleg allereie på plass, men sjekk med:

```sql
SELECT tablename, indexname 
FROM pg_indexes 
WHERE schemaname = 'public';
```
