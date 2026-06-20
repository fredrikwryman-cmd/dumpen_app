/// # Färgpalett och typografi för Dumpen-appen
///
/// Design baserad på dumpen.se's ChromeNews-tema.
/// Ljust tema: ljusa ytor, mörk text, utvalda accentfärger per kategori.
/// Kategorifärger matchar dumpen.se's category-color-X-klasser.
library;

import 'package:flutter/material.dart';

/// Appens standard-typsnitt (Jost-liknande, fungerar offline).
const String appFontFamily = 'sans-serif';

abstract final class AppColors {
  // === Basfärger (från dumpen.se — ljust tema) ===
  static const Color background      = Color(0xFFf0f0f0);  // Huvudbakgrund — ljusgrå
  static const Color surface         = Color(0xFFffffff);  // Kort / ytor — vit
  static const Color surfaceElevated = Color(0xFFf8f8f8);  // Högre kort / drawers
  static const Color surfaceLight    = Color(0xFFe8e8e8);  // Hover / pressed states
  static const Color foreground      = Color(0xFF1a1a1a);  // Primär text — nästan svart
  static const Color foregroundMuted = Color(0xFF666666);  // Sekundär text
  static const Color foregroundDark  = Color(0xFF9a9a9a);  // Diskret text / ikoner
  static const Color border          = Color(0xFFe0e0e0);  // Kantlinjer
  static const Color borderSubtle    = Color(0xFFeeeeee);  // Diskreta kanter

  // === Accentfärger ===
  static const Color accentYellow    = Color(0xFFFFCC00);  // Dumpen primär gul (#ffcc00)
  static const Color accentRed       = Color(0xFFEE2224);  // Utropsröd
  static const Color linkBlue        = Color(0xFF2563eb);  // Länkblå (mörkare för ljust tema)

  // === Statusfärger ===
  static const Color errorRed        = Color(0xFFdc2626);

  // === Kategorifärger (1:1 med dumpen.se's category-color-X) ===
  static const Map<int, Color> categoryColors = {
    1: Color(0xFFFFCC00),  // category-color-1: Gul
    2: Color(0xFF0987F5),  // category-color-2: Blå
    3: Color(0xFF202020),  // category-color-3: Mörk
    4: Color(0xFF46AF4B),  // category-color-4: Grön
    5: Color(0xFFEA8D03),  // category-color-5: Orange
    6: Color(0xFFFF5722),  // category-color-6: Djup orange
    7: Color(0xFF9C27B0),  // category-color-7: Lila
  };

  /// Hämtar kategorifärg, faller tillbaka på gul (Dumpens primärfärg).
  static Color categoryColor(int index) {
    return categoryColors[index] ?? accentYellow;
  }

  /// Textfärg som bredvidmatchar kategoribakgrund.
  static Color categoryTextColor(int index) {
    // Gul (#ffcc00) och Orange (#ea8d03) behöver mörk text, resten vit
    return (index == 1 || index == 5) ? Colors.black : Colors.white;
  }

  // === Hjälpare ===
  static Color get shimmerBackground => surface;
  static Color get shimmerHighlight  => surfaceLight;
}
