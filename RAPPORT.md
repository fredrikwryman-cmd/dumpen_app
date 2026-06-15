# Rapport — Dumpen App

**Datum:** 2026-06-14  
**Utförare:** Kimi Code CLI  
**Uppdrag:** Polish & stäng av kända brister, förberedelse för lokal test.

---

## Sammanfattning

Projektet `dumpen_app` är en Flutter-mobilapp för Dumpen.se. Under denna session genomfördes tre snabba kvalitetsfixar och förberedelser för lokal test. Alla planerade ändringar är genomförda och verifierade med textuell genomgång och grep.

---

## Utförda åtgärder

### FIX 1 — CategoryFeedScreen laddningstillstånd
**Problem:** Kategoriflödet visade tomma rutor (`SizedBox.shrink()`) medan inlägg laddades.  
**Lösning:** Ersatt med `ShimmerCard()` för att matcha hemskärmen.

| Fil | Rad | Ändring |
|---|---|---|
| `lib/screens/category_feed_screen.dart` | 12 | Ny import: `import '../widgets/shimmer_card.dart';` |
| `lib/screens/category_feed_screen.dart` | 130 | `const SizedBox.shrink()` → `const ShimmerCard()` |

### FIX 2 — Samtyckesdialog "Avbryt"
**Problem:** "Avbryt"-knappen i GDPR-samtyckesdialogen hade en tom callback och gjorde ingenting.  
**Lösning:** Lagt till `SystemNavigator.pop()` så att användaren kan stänga appen.

| Fil | Rad | Ändring |
|---|---|---|
| `lib/main.dart` | 201 | `onPressed: () {}` → `onPressed: () => SystemNavigator.pop()` |

### FIX 3 — Centraliserade konstanter
**Problem:** Swish-nummer, Swish-URL, hemside-URL och API-bas-URL var hårdkodade på flera ställen.  
**Lösning:** Skapat `lib/constants/app_constants.dart` som enda källa till sanning.

| Fil | Rad | Ändring |
|---|---|---|
| `lib/constants/app_constants.dart` | 1–13 | Ny fil med `AppConstants` |
| `lib/widgets/swish_banner.dart` | 10, 17 | Importerar `AppConstants`, använder `AppConstants.swishNumber` |
| `lib/screens/donate_screen.dart` | 13, 20–23 | Importerar `AppConstants`, använder det för `_swishUrl`, `_websiteUrl`, `_appShareText` |
| `lib/services/wordpress_api.dart` | 13, 18 | Importerar `AppConstants`, använder `AppConstants.apiBaseUrl` |
| `lib/services/wordpress_api.dart` | 3–4 | Uppdaterad dokumentationskommentar utan hårdkodad URL |

### FIX 4 — Sökskärmen: radera-knapp uppdateras inte
**Problem:** Radera-ikonen i sökfältet visades/doldes inte dynamiskt när användaren skrev eller rensade text.  
**Lösning:** Lagt till `onChanged: (_) => setState(() {})` på `TextField`.

| Fil | Rad | Ändring |
|---|---|---|
| `lib/screens/search_screen.dart` | 90 | Ny rad: `onChanged: (_) => setState(() {}),` |

### FIX 5 — Datum-lokal är nu konsekvent
**Problem:** `initializeDateFormatting('sv_SE', null)` initierade en locale men appen använde `'sv'` i `DateFormat`, vilket teoretiskt kunde ge engelska månadsnamn.  
**Lösning:** Bytt till `'sv_SE'` överallt.

| Fil | Rad | Ändring |
|---|---|---|
| `lib/screens/article_screen.dart` | 130 | `DateFormat('d MMMM y', 'sv')` → `DateFormat('d MMMM y', 'sv_SE')` |
| `lib/widgets/article_card.dart` | 23 | `DateFormat('d MMMM y', 'sv')` → `DateFormat('d MMMM y', 'sv_SE')` |

### FIX 6 — SnackBar-tema matchar mörkt UI
**Problem:** SnackBars hade default-utseende och kunde bli ljusa i den mörka appen.  
**Lösning:** Lagt till `snackBarTheme` i app-temat.

| Fil | Rad | Ändring |
|---|---|---|
| `lib/main.dart` | 93–99 | Ny `snackBarTheme: SnackBarThemeData(...)` |

### FIX 7 — Cachad lästid och författare återanvänds
**Problem:** `WpPost.toJson()` sparade `author_name` och `reading_time_minutes`, men `fromJson()` räknade alltid om dem.  
**Lösning:** `fromJson()` läser cachade värden om de finns, annars fallback till befintlig logik.

| Fil | Rad | Ändring |
|---|---|---|
| `lib/models/post.dart` | 143–153 | Läser `author_name` och `reading_time_minutes` från JSON vid cache-inläsning |

### Testförberedelse

| Uppgift | Status | Detalj |
|---|---|---|
| Skapa README.md | ✅ | `dumpen_app/README.md` skapad med bygginstruktioner |
| Verifiera pubspec.yaml | ✅ | Alla 10 dependencies bekräftade närvarande |
| Kontrollera imports | ✅ | Alla `.dart`-filer i `lib/` granskade. Inga saknade imports, inga absoluta `package:dumpen_app/...`-imports. `AppConstants` importeras korrekt i alla 3 konsumenter. |

---

## Verifiering av hårdkodade strängar

Grep efter känsliga strängar i `lib/`:

| Mönster | Resultat |
|---|---|
| `123-250` | Endast i `app_constants.dart:8` ✅ |
| `1232502284` | Endast i `app_constants.dart:10` ✅ |
| `https://dumpen.se` | Endast i `app_constants.dart:11–12` ✅ |
| `dumpen.se/wp-json` | Endast i `app_constants.dart:12` ✅ |

Alla strängar är nu centraliserade.

---

## Kvarstående blockerare / varningar

1. **Flutter inte tillgängligt i PATH**  
   Jag kan inte köra `flutter analyze`, `flutter pub get` eller `flutter run` i denna miljö. Detta måste göras på användarens dator.

2. **Tom assets-mapp**  
   `assets/` innehåller inga bilder eller ikoner än. Detta påverkar inte bygget, men bör fyllas om appen ska ha en egen ikon eller splash screen.

3. **Ingen git-historik**  
   Projektet har inget initierat git-repo. Rekommendation: initiera git och göra en första commit efter lyckad lokal test.

---

## Rekommenderade nästa steg

1. Användaren kör:
   ```bash
   cd C:/Users/fredr/dumpen_app
   flutter pub get
   flutter run
   ```
2. Rapportera eventuella felmeddelanden för felsökning.
3. Initiera git-repo och göra första commit.
4. Lägg till app-ikon och splash screen om önskat.
5. Bygga release-version för Android/iOS.

---

## Filstruktur (aktuell)

```
dumpen_app/
├── android/
├── assets/
├── ios/
├── lib/
│   ├── constants/
│   │   └── app_constants.dart      # NY
│   ├── models/
│   │   └── post.dart
│   ├── screens/
│   │   ├── article_screen.dart
│   │   ├── categories_screen.dart
│   │   ├── category_feed_screen.dart
│   │   ├── donate_screen.dart
│   │   ├── home_screen.dart
│   │   └── search_screen.dart
│   ├── services/
│   │   ├── cache_service.dart
│   │   └── wordpress_api.dart
│   ├── widgets/
│   │   ├── article_card.dart
│   │   ├── category_chip.dart
│   │   ├── shimmer_card.dart
│   │   └── swish_banner.dart
│   └── main.dart
├── pubspec.yaml
├── README.md                        # NY
└── RAPPORT.md                       # DENNA FIL
```

---

## Fortsatt arbete — 2026-06-14 (senare under dagen)

**Uppdrag:** Polering och nya features enligt användarens prioritering.

### FEATURE 1 — Centraliserad färgpalett
**Problem:** Appfärger (`#1a1a1a`, `#262626`, `#f5f5f5`, `#16a34a` m.fl.) var hårdkodade på tiotals ställen.  
**Lösning:** Skapat `lib/constants/app_colors.dart` som enda källa till sanning för alla färger och gråskalor.

| Fil | Ändring |
|---|---|
| `lib/constants/app_colors.dart` | Ny fil med `AppColors.background`, `.surface`, `.foreground`, `.primaryGreen`, `.linkBlue`, `.errorRed`, `.mutedGrey`, `.grey300–grey900` |
| `lib/main.dart` | Tema använder `AppColors` |
| `lib/models/post.dart` | `categoryColor`-fallback använder `AppColors.mutedGrey` |
| `lib/screens/*.dart` | Alla skärmar bytt till `AppColors` |
| `lib/widgets/*.dart` | Alla widgets bytt till `AppColors` |

Verifiering: Grep efter `Color(0xFF1a1a1a)` etc. returnerar endast träffar i `app_colors.dart`.

### FEATURE 2 — Offline-stöd för kategoriflöden och sök
**Problem:** Bara senaste inlägg, enskilda artiklar och kategorier cachades. Kategoriflöden och sök blev tomma offline.  
**Lösning:** Utökat `CacheService` och `WordPressApi` med cache/fallback för kategoriinlägg och sökresultat.

| Fil | Ändring |
|---|---|
| `lib/services/cache_service.dart` | Nya metoder: `saveCategoryPosts`, `getCategoryPosts`, `saveSearchResults`, `getSearchResults` |
| `lib/services/wordpress_api.dart` | `fetchPostsByCategory` och `searchPosts` cachar sidan 1 och faller tillbaka på cache vid `SocketException` |

### FEATURE 3 — Paginering och pull-to-refresh i sök
**Problem:** Sök returnerade max 10 träffar och gick inte att uppdatera genom att dra.  
**Lösning:** Omskriven `SearchScreen` med `ScrollController`, oändlig scroll och `RefreshIndicator`.

| Fil | Ändring |
|---|---|
| `lib/screens/search_screen.dart` | `_performSearch({required bool refresh})`, `_onScroll`, `_page`, `_hasMore`, `_isLoadingMore`, pull-to-refresh |

### FEATURE 4 — App-ikon, splash screen och git
**Problem:** Tom `assets/`-mapp, ingen versionshantering, ingen launcher/splash-konfiguration.  
**Lösning:** Skapat en placeholder-ikon, konfigurerat `flutter_launcher_icons` och `flutter_native_splash`, initierat git-repo och gjort första commiten.

| Fil | Ändring |
|---|---|
| `assets/icon.png` | Ny placeholder-ikon ("D" på mörk bakgrund) — bör bytas mot Dumpens riktiga logo |
| `pubspec.yaml` | Tillagda dev-dependencies `flutter_launcher_icons` och `flutter_native_splash` med konfiguration |
| `.git/` | Initierat repository |

Commit: `428633b feat: centralized colors, offline cache, search pagination, icon/splash setup`

### Kommandon att köra lokalt

Eftersom Flutter inte finns i PATH i denna miljö behöver användaren köra följande på sin egen dator:

```bash
cd C:/Users/fredr/dumpen_app
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
flutter analyze
flutter run
```

### Kvarstående saker

1. **Placeholder-ikon:** Ersätt `assets/icon.png` med Dumpens riktiga logo innan release.
2. **Flutter-test:** Måste köras lokalt eftersom Flutter inte är tillgängligt här.
3. **Eventuella analyzer-varningar:** Kan behöva justeras efter lokal `flutter analyze`.

---

*Rapporten är klar för överlämning till användaren och/eller fortsatt arbete av annan AI-agent.*
