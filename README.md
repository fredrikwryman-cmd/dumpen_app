# Dumpen App

En Flutter-app för Dumpen.se — barnrättsrörelsen som leds av
Sara Nilsson & Patrik Sjöberg.

## Förutsättningar

- Flutter SDK installerat (https://docs.flutter.dev/get-started/install)
- Android Studio eller Xcode för emulator/enhet

## Kom igång

1. Navigera till projektmappen: `cd dumpen_app`
2. Hämta dependencies: `flutter pub get`
3. Kör appen: `flutter run`

## Struktur

- `lib/models/` — Dataklasser (WpPost, WpCategory)
- `lib/services/` — API-klient och cache
- `lib/widgets/` — Återanvändbara widgets
- `lib/screens/` — Appens skärmar
- `lib/constants/` — Centraliserade konstanter

## API

Appen kopplar mot Dumpens WordPress REST API:
https://dumpen.se/wp-json/wp/v2

## Noteringar

- Första start visar en GDPR-samtyckesdialog
- Bilder cachas lokalt med CachedNetworkImage
- Swish-nummer: 123-250 22 84
