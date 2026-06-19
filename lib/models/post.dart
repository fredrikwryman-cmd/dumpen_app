/// # Data models för Dumpens WordPress REST API
///
/// Innehåller klasserna [WpPost], [WpCategory] och [WpMedia] med
/// `fromJson`-konstruktorer som hanterar Dumpens specifika API-svar.
library;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

// ---------------------------------------------------------------------------
// WpCategory
// ---------------------------------------------------------------------------

class WpCategory {
  final int id;
  final String name;
  final int count;
  final int colorIndex;

  const WpCategory({
    required this.id,
    required this.name,
    required this.count,
    required this.colorIndex,
  });

  Color get color => AppColors.categoryColor(colorIndex);
  Color get textColor => AppColors.categoryTextColor(colorIndex);

  factory WpCategory.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final override = kCategoryOverrideNames[id];
    final colorIdx = kCategoryColorIndex[id] ?? -1;
    return WpCategory(
      id: id,
      name: override ?? (json['name'] as String? ?? 'Okänd kategori'),
      count: json['count'] as int? ?? 0,
      colorIndex: colorIdx,
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

  String? urlForSize(String size) {
    final sizes = mediaDetails?['sizes'] as Map<String, dynamic>?;
    final sized = sizes?[size] as Map<String, dynamic>?;
    return sized?['source_url'] as String? ?? sourceUrl;
  }

  String? get mediumLarge => urlForSize('medium_large');
  String? get chromenewsLarge => urlForSize('chromenews-large');
  String? get full => sourceUrl;

  /// Bästa feed-bild: medium_large → chromenews-large → full.
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

    final cachedAuthor = json['author_name'] as String?;
    final authorName =
        cachedAuthor?.isNotEmpty == true ? cachedAuthor! : _resolveAuthorName(categories);

    final renderedContent = _rendered(json['content']);
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

  /// Kategorifärg för den dominerande kategorin.
  int get primaryColorIndex {
    for (final id in categories) {
      final idx = kCategoryColorIndex[id];
      if (idx != null && idx >= 0) return idx;
    }
    return 4; // fallback grön
  }

  Color get categoryColor => AppColors.categoryColor(primaryColorIndex);
  Color get categoryTextColor => AppColors.categoryTextColor(primaryColorIndex);

  String get categoryLabel => kCategoryOverrideNames[categories.first] ?? 'Dumpen';

  String get readingTimeLabel => '$readingTimeMinutes min läsning';

  /// Finns en featured-bild?
  bool get hasImage => featuredMedia?.feedUrl != null && featuredMedia!.feedUrl!.isNotEmpty;

  /// Rensad excerpt (HTML-taggar borta) — max [maxChars] tecken.
  String get plainExcerpt {
    final plain = excerpt
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
    return plain;
  }

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
    return 'Redaktör Dumpen';
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
