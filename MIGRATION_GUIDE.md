# Skaleringsfunksjonar - Migrasjonsguide

Denne guiden forklarer dei nye skaleringsfunksjonane og korleis du aktiverer dei i Supabase.

## 🎯 Nye Funksjonar

### 1. **Mengdefelt (Quantity)**
Registrer fleire like enheter på éin gang. I staden for å registrere 40 klasseromlamper individuelt, kan du no registrere:
- **Antall like enheter:** 40
- **Pærer per enhet:** 1
- **Totalt behov:** 40 pærer

### 2. **Strukturert Lokasjon**
Hierarkisk lokasjonssystem i staden for fritekstfelt:
- **Bygning:** "Hovedbygg"
- **Avdeling:** "Fløy B"
- **Detalj:** "2. etasje, klasserom 201"

Dette gjer filtrering enklare: "Vis alle lamper i Hovedbygg" eller "Vis alle E27 i Fløy B".

### 3. **Søk og Filter**
Kraftig søk- og filterfunksjonalitet:
- **Søk:** Fritekstøk i namn, bygning, avdeling, detalj
- **Filter på kategori:** Lamper / Batterier
- **Filter på type:** E27, GU10, AA, AAA osv.
- **Filter på bygning:** Vis utstyr i ein spesifikk bygning

## 🔧 Installasjon (KRITISK!)

### Steg 1: Køyr Database-migrasjon

Du **må** køyre SQL-migrasjonen i Supabase før du kan bruke dei nye funksjonane:

1. Logg inn på [Supabase Dashboard](https://app.supabase.com)
2. Vel prosjektet ditt
3. Gå til **SQL Editor** (ikon til venstre)
4. Kopier heile innhaldet frå `supabase_migration_quantity_location.sql`
5. Lim inn i SQL-editoren
6. Trykk **Run** (eller Cmd/Ctrl + Enter)

### Steg 2: Sjekk at Migrasjonen Fungerte

Køyr følgjande SQL for å verifisere:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'items' 
AND column_name IN ('quantity', 'building', 'department', 'detail');
```

Du skal sjå 4 rader:
- `quantity` - `integer`
- `building` - `text`
- `department` - `text`
- `detail` - `text`

### Steg 3: Test i Dev-miljøet

```bash
npm run dev
```

1. Gå til `/enheter`
2. Registrer ei ny lampe med:
   - **Antall like enheter:** 5
   - **Bygning:** Test
   - **Avdeling:** Fløy A
3. Sjekk at søk og filter fungerer

## 📊 Kva Blir Endra?

### Database (items-tabellen)
- ✅ Ny kolonne: `quantity INTEGER DEFAULT 1`
- ✅ Ny kolonne: `building TEXT`
- ✅ Ny kolonne: `department TEXT`
- ✅ Ny kolonne: `detail TEXT`
- ✅ Indeksar for rask filtrering (`type`, `category`, `building`, `department`)
- ℹ️ Gammal `location` blir bevart for bakoverkompatibilitet

### UI-endringer

**enheter.astro:**
- Nye felt i skjema: "Antall like enheter", "Bygning", "Avdeling", "Detalj"
- Søkeboks over utstyrslista
- Filter-dropdowns: Kategori, Type, Bygning
- "Nullstill filtre"-knapp

**InventoryCard.astro:**
- Viser `×40` badge i hjørnet om quantity > 1
- Viser strukturert lokasjon: "Hovedbygg / Fløy B / 2. etasje"
- Bytteformular spør "Hvor mange skal byttes?" når quantity > 1
- Lager-indikator viser "12/40" i staden for berre "12"

**beholdning.astro:**
- Auto-genererte lagerlinjer brukar `quantity × required_count` for terskelverdi
- Eksempel: 40 lamper med 1 pære kvar = terskel på 40

## 🧪 Test-scenario

Korleis teste at alt fungerer:

### Scenario 1: Bulk-registrering
1. Registrer 40 klasseromlamper (E27) i Hovedbygg / Fløy B
2. Sjekk at InventoryCard viser `×40` badge
3. Gå til beholdning - sjekk at terskel er 40 (ikkje 2)

### Scenario 2: Filtrering
1. Registrer lamper i ulike bygningar (Hovedbygg, Anneks)
2. Bruk bygningsfilter - sjekk at berre relevante lamper visast
3. Test typefilter (E27 vs GU10)
4. Test søk etter "klasserom"

### Scenario 3: Bulk-bytte
1. Registrer utstyr med quantity=10
2. Bytt 3 av 10 enheter
3. Sjekk at lager trekkjer frå korrekt (3 × required_count)

## 🔄 Bakoverkompatibilitet

**Eksisterande data:**
- Gammal `location`-felt blir bevart
- Viss `building`/`department`/`detail` er tomme, viser systemet `location` som fallback
- Viss `quantity` er NULL eller ikkje sett, brukar systemet `1` som standard

**Nullmigrasjon:**
- SQL-fila migrerer eksisterande `location` → `detail` automatisk
- Alle felt har `DEFAULT`-verdiar, så ingen data blir broten

## 📝 Notatar for Produksjon

- ⚠️ **Ta backup** før du køyrer migrasjon i produksjon
- ⚠️ Migrasjonen kan ikkje reverserast (legg til kolonner, slettar ikkje eksisterande)
- ✅ Ingen nedetid nødvendig - alle kolonner har DEFAULT-verdiar
- ✅ Eksisterande queries vil fungere (RLS-policies er uendra)

## 🐛 Feilsøking

**Problem:** "column items.quantity does not exist"
- **Løysing:** Du har ikkje køyrt SQL-migrasjonen. Gå til Steg 1.

**Problem:** Filter-dropdowns er tomme
- **Løysing:** Du har ingen data med `building`/`type` sett. Registrer nytt utstyr.

**Problem:** Søk finner ingenting
- **Løysing:** Søket brukar `ilike`, dobbeltsjekk at du har data i building/department/detail.

---

**Lykke til med testing! 🚀**

Viss du oppdagar feil, dokumenter dei i TESTPLAN.md under "Feil & Forbetringar".
