/// # Färgkodade kategorier för Dumpen
///
/// Mappar kategori-ID från WordPress API till färgindex 0..6
/// (motsvarar dumpen.se's `category-color-{idx + 1}`).
library;

/// Kategorifärgindex per WP-kategori-ID.
/// -1 betyder "ingen specifikation → använd fallback".
const Map<int, int> kCategoryColorIndex = {
  0:  -1, // "Senaste" / obestämd
  1:   0, // Patriks hörna / category-color-1  → gul
  11:  5, // Hall of Shame / category-color-6  → djuporange
  6:   0, // Krönika / category-color-1       → gul
  43:  0, // Krönikor / category-color-1      → gul
  26:  1, // Videos från gäddfiske / category-color-2 → blå
  60:  4, // Böcker och media … / category-color-5 → orange
  42:  6, // Mikaelas hörna / category-color-7 → lila
  22:  2, // Ansvarig utgivare / category-color-3 → mörk
  62:  3, // Föreningen Dumpen / category-color-4 → grön
  29:  1, // Rättsbevakning / category-color-2 → blå
};

const Map<int, String> kCategoryOverrideNames = {
  1:  'Patriks hörna',
  11: 'Hall of Shame',
  6:  'Krönika',
  43: 'Krönikor',
  26: 'Videos från gäddfiske',
  60: 'Böcker och media',
  42: 'Mikaelas hörna',
  22: 'Ansvarig utgivare',
  62: 'Föreningen Dumpen',
  29: 'Rättsbevakning',
};
