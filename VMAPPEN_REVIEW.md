# Granskning — vmappen.se

**Granskad:** 2026-06-13  
**Verktyg:** Kimi WebBridge (live browser)  
**Sessions:** Hem, Matcher, FanZone, Lag (Lagen), Mer  
**Teknisk genomgång:** PWA-manifest, service worker, meta-taggar

---

## 1. Övergripande bedömning av värdet

**VM-Appen 2026** är en svensk PWA (Progressive Web App) för fotbolls-VM 2026, tydligt riktad till svenska fans. Appen erbjuder:

- Nedräkning till nästa match
- Matchschema & live-resultat
- Gruppligor/tabeller
- Karta över 300 fanzoner/krogar i Sverige
- Nyheter, podd, tipspromenad, arenor, spelarinfo
- Support- och dela-funktioner

**Värdering:** Appen har **högt användarvärde för målgruppen** under VM-perioden. Den samlar flera funktioner som fans annars skulle behöva leta efter på olika ställen (SVT, FIFA, svenska krogar). Den är gratis, anonym och har en tydlig svensk vinkling (Sverige-knapp, svenska krogar).

**Kommersiellt värde:** Medierat. Potential finns i samarbeten med krogar, betting (Tippa), merchandise och donationer ("Stötta oss"). Livscykeln är dock bunden till VM 2026, så värdet är tidsbegränsat utan vidareutveckling.

---

## 2. Rent hantverksmässig bedömning

### 2.1 Design & UI

**Styrkor:**
- **Mörkt, sportigt tema** med gula/blå accentfärger som känns svenskt och passar VM.
- **Tydlig hierarki:** Stora siffror, flaggor och kontraster gör informationen lätt att skanna.
- **Konsistent visuellt språk:** Runda hörn, genomskinliga kort, stadionbakgrund.
- **Mobilanpassad layout:** Viewport `width=device-width, initial-scale=1.0, viewport-fit=cover`, vilket indikerar att den är tänkt som mobilapp/PWA.
- **Bottom navigation** med tydliga ikoner och etiketter.

**Svagheter:**
- **UI-bug:** När man navigerar tillbaka till "Hem" förblir "FanZone"-fliken visuellt aktiv (gul) samtidigt som "Hem" får en liten prick. Detta är en tydlig tillståndsfel.
- **Överlappning:** PWA-installationsbannern täcker delar av innehållet på flera skärmar. En "Inte nu"-knapp finns, men den visas upprepade gånger.
- **Kartan i FanZone** är funktionell men ser något rörig ut när många markörer klustras.

### 2.2 UX & Interaktion

**Styrkor:**
- **Tydliga CTA-knappar:** "Jag förstår", "Installera", "Stötta oss", "Dela appen".
- **Samtyckesmodal vid första besök** som förklarar att appen är fristående och inte officiell — bra för juridisk transparens.
- **Sverige-fokus:** Enkelt att filtrera matcher efter Sverige och hitta svenska fanzoner.

**Svagheter:**
- **Ingen meta description** (`<meta name="description">` saknas). Detta påverkar SEO negativt.
- **Settings-sidan** känns outnyttjad — "Skapa profil" leder troligen ingenstans än (ingen vidare utforskning gjordes).
- **Notiser:** Push-notiser är listade i inställningar, men det är oklart om de fungerar utan att användaren godkänt webbnotiser i webbläsaren.

### 2.3 Tekniskt hantverk

**Styrkor:**
- **PWA-ready:** Har `manifest.webmanifest`, service worker och theme-color (`#070d1a`).
- **Responsiv viewport** med `viewport-fit=cover` för moderna mobiler.
- **Kartan använder Leaflet + OpenStreetMap/CARTO** — en beprövad, kostnadsfri lösning.
- **Live-data:** Matcherna uppdateras i realtid (visade "LIVE 63'" för Qatar–Schweiz).

**Svagheter:**
- **Ingen tydlig frontend-ramverkssignatur** (ingen React/Vue/Angular/Next.js). Detta kan betyda att mycket är handbyggt med vanilj JS, vilket är flexibelt men kan vara svårare att underhålla i längden.
- **Ingen meta description** — enkelt men viktigt SEO-fel.
- **Service worker finns**, men det är oklart om offline-funktionalitet fungerar väl.

---

## 3. Personlig åsikt om hur den ser ut

**Mitt omdöme: Snygg och engagerande, men lite "template-aktig" på sina håll.**

- **Färgval:** Mörkblå bakgrund med gult och vitt fungerar utmärkt. Det känns sportigt, nattligt (matchtider) och svenskt utan att vara för mycket flagg nationalism.
- **Typografi:** Stora, feta rubriker i versaler ger energi. Brödtexten är läsbar.
- **Flaggor och ikoner:** Runda landsflaggor och gula ikoner är lätt igenkännliga.
- **Bakgrundsbild:** Stadionbilden med publik skapar stämning, men den gör också vissa kort lite svårlästa där kontrasten sjunker.
- **Bottom nav:** Tydlig och lättanvänd, men den markerade FanZone-buggen drar ner helhetsintrycket.
- **FanZone-kartan:** Känns som en av de starkare funktionerna — det är något konkret och användbart för svenska fans.

**Sammantaget:** Appen ser **professionell ut på distans**, men har småpolish-problem som skulle behöva åtgärdas innan en större lansering. Den känns mer som en välgjord hobbyprojekt-app än en kommersiell produkt — vilket inte nödvändigtvis är dåligt för målgruppen.

---

## 4. Hittade brister (i prioritetsordning)

1. **UI-bug i bottom navigation:** FanZone förblir markerad när man går till Hem.
2. **Saknad meta description:** Påverkar SEO.
3. **PWA-banner täcker innehåll:** Kan vara irriterande vid upprepad visning.
4. **Oklar profilfunktion:** "Skapa profil" verkar inte leda någonstans än.
5. **Kontrast på vissa kort:** Stadionbakgrunden kan göra text svårläst.

---

## 5. Rekommendationer

**Kortsiktigt (före VM):**
- Fixa bottom-nav-tillståndet.
- Lägg till `<meta name="description">`.
- Justera PWA-banner så den inte täcker viktigt innehåll, eller visa den max en gång per session.
- Testa push-notiser och profilflödet.

**Långsiktigt:**
- Fundera på hur appen kan leva vidare efter VM 2026 (t.ex. EM 2028, allsvenskan, eller återanvändning av FanZone-konceptet).
- Bygg in analytics för att förstå vilka flikar som används mest.
- Överväg att lägga till delbara matchkort/highlights för social spridning.

---

## 6. Slutbetyg

| Kategori | Betyg (1–5) | Kommentar |
|---|---|---|
| Visuell design | 4/5 | Snygg, sportig, svensk — men något template-känsla |
| Användarupplevelse | 3.5/5 | Bra flöde, men navigationen har en tydlig bug |
| Tekniskt hantverk | 3.5/5 | PWA-ready, men saknar meta description och tydligt ramverk |
| Funktionsinnehåll | 4.5/5 | Mycket innehåll för VM-fans |
| Kommersiell potential | 3/5 | Hög under VM, låg efteråt utan vidareutveckling |
| **Totalt** | **3.7/5** | En välgjord, användbar fan-app med några småfixar kvar |
