/// # Runtime-konfiguration — avgör om vi kör via lokal proxy eller direkt.
library;
///
/// - Web (hosted): använder alltid direkt anrop (kräver CORS-stöd eller proxy)
/// - Web (via serve_web.py): `/proxy` vidarebefordrar till dumpen.se
/// - Mobil (direkt): `https://dumpen.se/wp-json/wp/v2`

import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  /// Bas-URL för alla dumpen.se-requests.
  static String get apiBaseUrl {
    // Direkt anrop — fungerar om dumpen.se har CORS-headrar,
    // annars krävs proxy (serve_web.py lokalt).
    return 'https://dumpen.se/wp-json/wp/v2';
  }

  /// Proxy-prefix för bilder och media.
  /// I web-läge via serve_web.py lägger vi till `/proxy` framför dumpen.se-URL:er.
  static String proxyUrl(String url) {
    if (!kIsWeb) return url;
    // När vi kör via serve_web.py lokalt, byt till proxy
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
