/// # Artikelkort för nyhetsfeeden
///
/// Visar utvald bild, titel, kategori-badge, datum och lästid. Bilderna
/// laddas med [CachedNetworkImage] för snabb återvisning och offline-stöd.
/// Ingen möjlighet att spara bilder finns implementerad.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';

class ArticleCard extends StatelessWidget {
  final WpPost post;
  final VoidCallback onTap;

  const ArticleCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM y', 'sv_SE');
    final imageUrl = post.featuredMedia?.feedUrl;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.shimmerBase,
                        highlightColor: AppColors.shimmerHighlight,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.grey900,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.grey900,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: post.categoryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: post.categoryColor, width: 1),
                    ),
                    child: Text(
                      post.categoryLabel.toUpperCase(),
                      style: TextStyle(
                        color: post.categoryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.readingTimeMinutes} min läsning',
                        style: TextStyle(color: AppColors.grey400),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(post.date),
                        style: TextStyle(color: AppColors.grey400),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
