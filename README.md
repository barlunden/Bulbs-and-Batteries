# 🛠️ Vidar-Logg
**Den digitale hovudnøkkelen for moderne vaktmeistrar.**

Vidar-Logg er eit vedlikehaldssystem skreddarsydd for personar som administrerer utstyr og lager over fleire lokasjonar – frå skular og næringsbygg til private heim. Systemet gjer det enkelt å loggføre bytte av lyspærer, batteri og anna forbruksmateriell med full historikk.

---

## ✨ Hovudfunksjonar
- **Organisasjonsstyring:** Byte saumlaust mellom ulike bygg (t.eks. "Pærebråten skule" og "Lampevegen 20").
- **Fleirbrukar-tilgang:** Del inventar med teamet ditt gjennom e-postinvitasjonar. Rollestyre for admin/medlem.
- **Skalerbar Registrering:** Registrer "40 klasseromlamper" i eitt skjema med mengdefelt.
- **Strukturert Lokasjon:** Filtrer utstyr etter bygning/avdeling/detalj (t.d. "Hovedbygg / Fløy B / 2. etasje").
- **Kraftig Søk & Filter:** Finn raskt "alle E27-lamper i Fløy B" eller søk etter nøkkelord.
- **Smart Lager:** Automatisk fråtrekk frå beholdning ved bytte av deler, med full historikk.
- **Detaljert Enhetslogg:** Spesifikasjonar for kvar lampe (sokkel, form, Kelvin, dimbarheit).
- **Historikk:** Sjå nøyaktig kor mange dagar det er sidan sist vedlikehald for å avdekke feilvarer.

## 🚀 Teknologi
Prosjektet er bygd med ein moderne "tech stack" for fart og tryggleik:
- **Framework:** [Astro](https://astro.build/) (Server-side rendering for optimal fart)
- **Database & Auth:** [Supabase](https://supabase.com/) (PostgreSQL med Row Level Security)
- **Språk:** [TypeScript](https://www.typescriptlang.org/) (Type-sikkerheit gjennom heile appen)
- **Styling:** [Tailwind CSS](https://tailwindcss.com/) (Responsivt og moderne design)

## 🛠️ Installasjon
1. Klone repoet: `git clone https://github.com/brukarnamn/vidar-logg.git`
2. Installer avhengigheiter: `npm install`
3. Set opp `.env` med dine Supabase-nøklar:
   ```text
   PUBLIC_SUPABASE_URL=din_url
   PUBLIC_SUPABASE_ANON_KEY=din_nøkkel
   ```
4. Køyr database-migrasjonar i Supabase Dashboard (SQL Editor):
   - `supabase_migration_profiles.sql` - Profiltabell for e-postinvitasjonar
   - `supabase_migration_quantity_location.sql` - Mengdefelt og strukturert lokasjon
5. Start dev-server: `npm run dev`

Sjå [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for detaljar om database-oppsett.