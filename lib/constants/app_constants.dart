/// # App-konstanter för Dumpen
///
/// Centraliserade strängar och URL:er som används på flera ställen i appen.
library;

import 'app_config.dart';

class AppConstants {
  static const String appName = 'DUMPEN';
  static const String swishNumber = '123-250 22 84';
  static const String swishUrl =
      'swish://payment?data=%7B%22version%22%3A1%2C%22payee%22%3A%7B%22value%22%3A%221232502284%22%7D%7D';
  static const String dumpenWebsite = 'https://dumpen.se';
  static const String apiBaseUrl = 'https://dumpen.se/wp-json/wp/v2';

  /// Runtime-baserad API-URL (byter till proxy i web-läge).
  static String get runtimeApiBaseUrl => AppConfig.apiBaseUrl;

  /// Kategorier som visas i hero/snabbval på förstasidan.
  static const List<Map<String, dynamic>> topCategoryFilters = [
    {'id': 0,    'name': 'Senaste',      'colorIdx': 4},
    {'id': 11,   'name': 'Hall of Shame', 'colorIdx': 6},
    {'id': 6,    'name': 'Krönika',       'colorIdx': 1},
    {'id': 43,   'name': 'Krönikor',      'colorIdx': 1},
    {'id': 26,   'name': 'Videos',         'colorIdx': 2},
    {'id': 29,   'name': 'Rättsbevakning', 'colorIdx': 5},
  ];
}
