# 🧪 Testplan - Bulbs & Batteries

## Før du starter testing

### Forutsetninger
- ✅ Lokal testing kun (ikke produksjon ennå)
- ✅ Kjør `npm run dev` i terminal
- ✅ URL: http://localhost:4322 (eller annen tilgjengelig port)
- ✅ Testbrukere må være på samme nettverk eller ha tilgang til din lokale server

### Kjente begrensninger
- ⚠️ Produksjon (Netlify) har cookie-problemer - ikke deploy ennå
- ⚠️ Testing kun på localhost

---

## Fase 1: Solo-testing (deg selv)

### ✅ Autentisering
- [ ] Registrer deg på /login (hvis ikke allerede gjort)
- [ ] Logg ut
- [ ] Logg inn igjen
- [ ] Sjekk at du blir redirectet til forsiden

### ✅ Husstand
- [ ] Gå til /vel-hus
- [ ] Opprett et nytt hus (f.eks. "Testskolen")
- [ ] Bytt mellom hus hvis du har flere
- [ ] Gå til /husstand (Team-knappen i menyen)
- [ ] Sjekk at du er admin
- [ ] Se din e-postadresse i medlemslisten

### ✅ Enheter (utstyr)
- [ ] Legg til 3 lamper:
  - Lampe 1: E27, pære, dimbar, varm hvit
  - Lampe 2: GU10, spot, ikke dimbar, kald hvit
  - Lampe 3: E14, pære, dimbar, varm hvit
- [ ] Legg til 2 batteriutstyr:
  - Røykvarsler: AAA, ikke oppladbar, 3 stk
  - Lommelykt: AA, oppladbar, 2 stk
- [ ] Sjekk at alle vises i listen

### ✅ Beholdning (lager)
- [ ] Gå til /beholdning
- [ ] Sjekk at det ble auto-generert beholdning for dine enheter
- [ ] Legg til 10 stk E27 dimbare pærer på lager
- [ ] Legg til 5 stk GU10 ikke-dimbare spots
- [ ] Legg til 12 stk AAA batterier (ikke oppladbare)
- [ ] Sjekk at "DIM" badge vises på dimbare pærer
- [ ] Sjekk at "♻️" badge vises på oppladbare batterier

### ✅ Bytte pærer/batterier
- [ ] Gå tilbake til /enheter
- [ ] Klikk "BYTT" på Lampe 1
- [ ] Sjekk at lagerbeholdningen for E27 dimbare gikk ned med 1
- [ ] Sjekk at "Sist byttet" viser "I dag"
- [ ] Vent 1 minutt, refresh, sjekk fortsatt "I dag"
- [ ] Bytt batterier i Røykvarsler
- [ ] Sjekk at AAA-lageret gikk ned med 3

### ✅ Handleliste
- [ ] Gå til /beholdning
- [ ] Sett min terskel til 8 for E27 dimbare
- [ ] Bruk noen pærer (bytt flere ganger) til du kommer under 8
- [ ] Sjekk at E27 dimbare dukker opp i handlelisten øverst
- [ ] Kjøp inn 20 nye, sjekk at den forsvinner fra handlelisten

---

## Fase 2: Testing med én testbruker

### Forberedelser
- [ ] Be testbruker om å registrere seg på http://localhost:4322/login
- [ ] Be dem sende deg deres e-postadresse (vises på forsiden)

### ✅ Invitasjon
- [ ] Gå til /husstand (Team)
- [ ] Skriv inn testbrukerens e-post
- [ ] Velg rolle: "Medlem"
- [ ] Klikk "LEGG TIL MEDLEM"
- [ ] Sjekk at de dukker opp i medlemslisten

### ✅ Testbrukerens side
Be testbrukeren gjøre følgende:
- [ ] Gå til /vel-hus (Bygg-knappen)
- [ ] Velg huset du inviterte dem til
- [ ] Sjekk at de kommer til forsiden
- [ ] Gå til /enheter - sjekk at de ser dine enheter
- [ ] Prøv å bytte en pære - sjekk at det fungerer
- [ ] Gå til /beholdning - sjekk at de ser lageret
- [ ] Prøv å kjøpe inn pærer - sjekk at det fungerer
- [ ] Gå til /husstand - sjekk at de IKKE ser invitasjonsskjema (kun medlem)

### ✅ Data-isolering
- [ ] Be testbruker om å opprette sitt eget hus på /vel-hus
- [ ] De legger til 1 lampe i sitt eget hus
- [ ] Bytt tilbake til ditt hus (vel-hus)
- [ ] Sjekk at du IKKE ser testbrukerens lampe
- [ ] Testbruker bytter til sitt hus
- [ ] De skal IKKE se dine lamper

### ✅ Roller og tilgang
- [ ] Gå til /husstand
- [ ] Endre testbrukerens rolle til "Administrator"
- [ ] Be dem refreshe siden
- [ ] De skal nå se invitasjonsskjema
- [ ] Be dem invitere en tredjebruker (hvis du har)
- [ ] Endre tilbake til "Medlem"
- [ ] Sjekk at skjemaet forsvinner

---

## Fase 3: Samtidig bruk (viktig!)

### ✅ Samtidig redigering
Utfør disse samtidig med testbruker:
- [ ] Dere bytter samme lampe samtidig (samme sekund)
- [ ] Sjekk at lageret går ned korrekt (2 stk)
- [ ] Dere kjøper inn pærer samtidig
- [ ] Sjekk at begge innkjøpene registreres
- [ ] Dere ser på /beholdning samtidig
- [ ] Du endrer en terskel
- [ ] Testbruker refresher - skal se din endring

### ✅ Real-world scenario
Simuler realistisk bruk:
- [ ] Testbruker er "på butikken" (i annet rom)
- [ ] De åpner /beholdning på mobil
- [ ] Ser handlelisten
- [ ] Du endrer handlelisten samtidig
- [ ] De refresher - skal se dine endringer

---

## Fase 4: Edge cases og feilhåndtering

### ✅ Feilsituasjoner
- [ ] Prøv å bytte pære når lager er tomt - hva skjer?
- [ ] Prøv å legge til medlem med ugyldig e-post
- [ ] Prøv å legge til samme medlem to ganger
- [ ] Prøv å fjerne deg selv som medlem
- [ ] Logg ut midt i en handling - fungerer pålogging igjen?

### ✅ Datavalidering
- [ ] Prøv negative tall i lagerbeholdning
- [ ] Prøv ekstremt store tall (999999)
- [ ] Prøv tomme felt i skjemaer
- [ ] Prøv spesialtegn i husstandsnavn

---

## Sjekkliste før produksjon

### 🔴 Kritiske issues (må fikses)
- [ ] Cookie-autentisering på Netlify
- [ ] Supabase redirect URLs for produksjon
- [ ] HTTPS/secure cookies

### 🟡 Nice-to-have (kan vente)
- [ ] Fjern alle console.log
- [ ] Legg til loading-states på knapper
- [ ] Bedre feilmeldinger
- [ ] "Global notat"-redigering fungerer ikke

### ✅ Når alt er grønt
- [ ] Commit og push alle endringer
- [ ] Deploy til Netlify
- [ ] Test autentisering i produksjon
- [ ] Test med én produksjonsbruker først
- [ ] Så åpne for flere!

---

## 📝 Notater fra testing

Skriv ned alt som virker rart eller som kan forbedres:

**Bugs funnet:**
- 

**Forbedringsforslag:**
- 

**Spørsmål:**
- 

---

## 🎯 Suksesskriterier

Testing er vellykket når:
1. ✅ To brukere kan jobbe samtidig uten konflikter
2. ✅ Data er isolert mellom husstander
3. ✅ Invitasjonssystemet fungerer sømløst
4. ✅ Ingen kritiske bugs funnet
5. ✅ Testbrukerne forstår hvordan appen fungerer

**Lykke til med testingen! 🚀**
