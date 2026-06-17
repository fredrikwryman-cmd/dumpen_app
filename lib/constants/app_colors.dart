/// # Färgpalett för Dumpen-appen
///
/// Centraliserade färger så att temaändringar bara behöver göras på ett ställe.
/// Alla skärmar och widgets ska hämta sina färger härifrån i första hand.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // Basfärger
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1e1e1e);
  static const Color surfaceHighlight = Color(0xFF2a2a2a);
  static const Color foreground = Color(0xFFf5f5f5);
  static const Color foregroundMuted = Color(0xFFa3a3a3);

  // Accentfärger
  static const Color primaryGreen = Color(0xFF22c55e);
  static const Color primaryGreenDim = Color(0xFF16a34a);
  static const Color linkBlue = Color(0xFF60a5fa);
  static const Color errorRed = Color(0xFFef4444);
  static const Color mutedGrey = Color(0xFF6b7280);

  // Kantlinjer och dividers
  static const Color border = Color(0xFF333333);
  static const Color borderSubtle = Color(0xFF262626);

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
