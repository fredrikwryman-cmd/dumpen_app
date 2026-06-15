/// # Data models för Dumpens WordPress REST API
///
/// Innehåller klasserna [WpPost], [WpCategory] och [WpMedia] med
/// `fromJson`-konstruktorer som hanterar Dumpens specifika API-svar,
/// inklusive fallback för författare (som ger 404 från author-embed).
library;

import 'package:flutter/material.dart';

import 'constants/app_colors.dart';

// ---------------------------------------------------------------------------
// Kategorikonfiguration — färg och namn för de kategorier som appen exponerar.
// ---------------------------------------------------------------------------

const Map<int, Map<String, String>> _categoryConfig = {
  11: {'name': 'Hall of shame', 'color': '#8c2a2a'},
  6: {'name': 'Krönika', 'color': '#2563eb'},
  43: {'name': 'Krönikor', 'color': '#2563eb'},
  26: {'name': 'Videos från gäddfiske', 'color': '#7c3aed'},
  60: {'name': 'Böcker och media om sexuella övergrepp mot barn', 'color': '#ea580c'},
  42: {'name': 'Mikaelas hörna', 'color': '#ec4899'},
  22: {'name': 'Ansvarig utgivare', 'color': '#6b7280'},
  1: {'name': 'Patriks Hörna', 'color': '#1e40af'},
  62: {'name': 'Föreningen Dumpen', 'color': '#16a34a'},
  29: {'name': 'Rättsbevakning', 'color': '#4338ca'},
};

/// Returnerar en [Color] från en hex-sträng i formatet `#rrggbb`.
Color _colorFromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

// ---------------------------------------------------------------------------
// WpCategory
// ---------------------------------------------------------------------------

class WpCategory {
  final int id;
  final String name;
  final int count;
  final Color color;

  const WpCategory({
    required this.id,
    required this.name,
    required this.count,
    required this.color,
  });

  factory WpCategory.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final config = _categoryConfig[id];
    return WpCategory(
      id: id,
      name: config?['name'] ?? (json['name'] as String? ?? 'Okänd kategori'),
      count: json['count'] as int? ?? 0,
      color: _colorFromHex(config?['color'] ?? '#6b7280'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'count': count,
      };
}

// ---------------------------------------------------------------------------
// WpMedia
// ---------------------------------------------------------------------------

class WpMedia {
  final int? id;
  final String? sourceUrl;
  final Map<String, dynamic>? mediaDetails;

  const WpMedia({this.id, this.sourceUrl, this.mediaDetails});

  factory WpMedia.fromJson(Map<String, dynamic> json) {
    return WpMedia(
      id: json['id'] as int?,
      sourceUrl: json['source_url'] as String?,
      mediaDetails: json['media_details'] as Map<String, dynamic>?,
    );
  }

  /// Hämtar bild-URL för önskad storlek. Fall tillbaka på `sourceUrl`
  /// om storleken inte finns.
  String? urlForSize(String size) {
    final sizes = mediaDetails?['sizes'] as Map<String, dynamic>?;
    final sized = sizes?[size] as Map<String, dynamic>?;
    return sized?['source_url'] as String? ?? sourceUrl;
  }

  String? get mediumLarge => urlForSize('medium_large');
  String? get chromenewsLarge => urlForSize('chromenews-large');
  String? get full => sourceUrl;

  /// Bästa feed-bild: medium_large, annars chromenews-large, annars full.
  String? get feedUrl => mediumLarge ?? chromenewsLarge ?? full;
}

// ---------------------------------------------------------------------------
// WpPost
// ---------------------------------------------------------------------------

class WpPost {
  final int id;
  final DateTime date;
  final String title;
  final String content;
  final String excerpt;
  final String link;
  final List<int> categories;
  final WpMedia? featuredMedia;
  final String authorName;
  final int readingTimeMinutes;

  WpPost({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.link,
    required this.categories,
    this.featuredMedia,
    required this.authorName,
    required this.readingTimeMinutes,
  });

  factory WpPost.fromJson(Map<String, dynamic> json) {
    final categories = <int>[];
    final rawCategories = json['categories'];
    if (rawCategories is List) {
      for (final c in rawCategories) {
        if (c is int) categories.add(c);
      }
    }

    // Author-embed returnerar 404 på Dumpen.se; använd sparad/cachad
    // författare om den finns, annars kategoribaserad fallback.
    final cachedAuthor = json['author_name'] as String?;
    final authorName =
        cachedAuthor?.isNotEmpty == true ? cachedAuthor! : _resolveAuthorName(categories);

    final renderedContent = _rendered(json['content']);

    // Läs cached lästid om den finns, annars räkna om från innehållet.
    final cachedReadingTime = json['reading_time_minutes'] as int?;
    final readingTimeMinutes = cachedReadingTime ?? _estimateReadingTime(renderedContent);

    return WpPost(
      id: json['id'] as int? ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      title: _rendered(json['title']),
      content: renderedContent,
      excerpt: _rendered(json['excerpt']),
      link: json['link'] as String? ?? '',
      categories: categories,
      featuredMedia: _extractFeaturedMedia(json['_embedded']),
      authorName: authorName,
      readingTimeMinutes: readingTimeMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': {'rendered': title},
        'content': {'rendered': content},
        'excerpt': {'rendered': excerpt},
        'link': link,
        'categories': categories,
        'author_name': authorName,
        'reading_time_minutes': readingTimeMinutes,
      };

  /// Den dominerande kategorin för ett inlägg (den första från konfigurationen).
  /// Används för badge-färg och kategorinamn.
  WpCategory? get primaryCategory {
    for (final id in categories) {
      final config = _categoryConfig[id];
      if (config != null) {
        return WpCategory(
          id: id,
          name: config['name']!,
          count: 0,
          color: _colorFromHex(config['color']!),
        );
      }
    }
    return null;
  }

  /// Första bästa konfigurerade kategorinamn, eller generisk etikett.
  String get categoryLabel => primaryCategory?.name ?? 'Dumpen';

  /// Accentfärg för inläggets kategori.
  Color get categoryColor => primaryCategory?.color ?? AppColors.mutedGrey;

  // -------------------------------------------------------------------------
  // Hjälpare
  // -------------------------------------------------------------------------

  static String _rendered(Map<String, dynamic>? field) {
    if (field == null) return '';
    final rendered = field['rendered'];
    return rendered is String ? rendered : '';
  }

  static WpMedia? _extractFeaturedMedia(Map<String, dynamic>? embedded) {
    final mediaList = embedded?['wp:featuredmedia'];
    if (mediaList is List && mediaList.isNotEmpty) {
      final first = mediaList.first;
      if (first is Map<String, dynamic>) {
        return WpMedia.fromJson(first);
      }
    }
    return null;
  }

  static String _resolveAuthorName(List<int> categories) {
    if (categories.contains(42)) return 'Mikaela';
    if (categories.contains(1)) return 'Patrik Sjöberg';
    return 'Sara Nilsson & Patrik Sjöberg';
  }

  static int _estimateReadingTime(String html) {
    final plain = html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.isEmpty) return 1;
    final wordCount = plain.split(' ').length;
    return ((wordCount / 200).ceil()).clamp(1, 999);
  }
}
