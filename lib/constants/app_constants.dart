/// # App-konstanter för Dumpen
///
/// Centraliserade strängar och URL:er som används på flera ställen i appen.
/// Ändras ett värde här så sprids det automatiskt till alla konsumenter.
library;

class AppConstants {
  static const String swishNumber = '123-250 22 84';
  static const String swishUrl =
      'swish://payment?data=%7B%22version%22%3A1%2C%22payee%22%3A%7B%22value%22%3A%221232502284%22%7D%7D';
  static const String dumpenWebsite = 'https://dumpen.se';
  static const String apiBaseUrl = 'https://dumpen.se/wp-json/wp/v2';
}
