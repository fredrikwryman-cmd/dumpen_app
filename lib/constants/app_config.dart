/// # Runtime-konfiguration — avgör om vi kör via lokal proxy eller direkt.
library;
///
/// I web-läge när appen servas via [serve_web.py] behöver alla
/// dumpen.se-requests gå genom proxyn för att undvika CORS-blockering.
/// I mobil-läge (Android/iOS) ansluter vi direkt.

import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  /// Bas-URL för alla dumpen.se-requests.
  ///
  /// - Web (via proxy): `/proxy` → proxyn vidarebefordrar till dumpen.se
  /// - Mobil (direkt):  `https://dumpen.se/wp-json/wp/v2`
  static String get apiBaseUrl {
    if (kIsWeb) return '/proxy/wp-json/wp/v2';
    return 'https://dumpen.se/wp-json/wp/v2';
  }

  /// Proxy-prefix för bilder och media.
  /// I web-läge lägger vi till `/proxy` framför alla dumpen.se-URL:er.
  static String proxyUrl(String url) {
    if (!kIsWeb) return url;
    if (url.startsWith('https://dumpen.se')) {
      return '/proxy${url.substring('https://dumpen.se'.length)}';
    }
    if (url.startsWith('http://dumpen.se')) {
      return '/proxy${url.substring('http://dumpen.se'.length)}';
    }
    return url;
  }

  /// Bas-URL för dumpen.se (utan proxy).
  static const String dumpenBaseUrl = 'https://dumpen.se';
}
