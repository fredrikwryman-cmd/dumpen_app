/// # Färgpalett för Dumpen-appen
///
/// Centraliserade färger så att temaändringar bara behöver göras på ett ställe.
/// Alla skärmar och widgets ska hämta sina färger härifrån i första hand.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // Basfärger
  static const Color background = Color(0xFF1a1a1a);
  static const Color surface = Color(0xFF262626);
  static const Color foreground = Color(0xFFf5f5f5);

  // Accentfärger
  static const Color primaryGreen = Color(0xFF16a34a);
  static const Color linkBlue = Color(0xFF60a5fa);
  static const Color errorRed = Color(0xFFef4444);
  static const Color mutedGrey = Color(0xFF6b7280);

  // Gråskalor som används konsekvent i UI:t
  static Color grey300 = Colors.grey.shade300;
  static Color grey400 = Colors.grey.shade400;
  static Color grey500 = Colors.grey.shade500;
  static Color grey600 = Colors.grey.shade600;
  static Color grey700 = Colors.grey.shade700;
  static Color grey800 = Colors.grey.shade800;
  static Color grey900 = Colors.grey.shade900;

  // Hjälpare för shimmer/loader
  static Color get shimmerBase => grey800;
  static Color get shimmerHighlight => grey700;
}
