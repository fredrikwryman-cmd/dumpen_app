/// # Artikelvisning
///
/// Visar en enskild artikel med hero-bild, titel, metadata, HTML-brödtext,
/// Swish-banner, dela-knapp och öppna-i-webbläsare-knapp.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/swish_banner.dart';

class ArticleScreen extends StatefulWidget {
  final int postId;

  const ArticleScreen({super.key, required this.postId});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final WordPressApi _api = WordPressApi();
  WpPost? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final post = await _api.fetchPost(widget.postId);
      if (mounted) {
        setState(() {
          _post = post;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareArticle() async {
    final link = _post?.link;
    if (link == null || link.isEmpty) return;
    await Share.share(link, subject: _post?.title);
  }

  Future<void> _openInBrowser() async {
    final link = _post?.link;
    if (link == null || link.isEmpty) return;
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              ShimmerCard(),
              Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      );
    }

    if (_error != null || _post == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.foreground),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                'Kunde inte ladda artikeln.',
                style: TextStyle(color: AppColors.grey400),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.foreground,
                ),
                child: const Text('Försök igen'),
              ),
            ],
          ),
        ),
      );
    }

    final post = _post!;
    final dateFormat = DateFormat('d MMMM y', 'sv_SE');
    final heroImage = post.featuredMedia?.full ?? post.featuredMedia?.feedUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            pinned: true,
            iconTheme: const IconThemeData(color: AppColors.foreground),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.foreground),
                tooltip: 'Dela artikel',
                onPressed: _shareArticle,
              ),
              IconButton(
                icon: const Icon(Icons.open_in_browser, color: AppColors.foreground),
                tooltip: 'Öppna i webbläsare',
                onPressed: _openInBrowser,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero-bild
                if (heroImage != null && heroImage.isNotEmpty)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: heroImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.grey900,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.grey900,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori-badge
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
                      const SizedBox(height: 16),
                      // Titel
                      Text(
                        post.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                      ),
                      const SizedBox(height: 16),
                      // Metadata
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              post.authorName,
                              style: TextStyle(color: AppColors.grey400),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.readingTimeMinutes} min läsning',
                            style: TextStyle(color: AppColors.grey400),
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dateFormat.format(post.date),
                            style: TextStyle(color: AppColors.grey400),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // HTML-innehåll
                      Html(
                        data: post.content,
                        style: {
                          'body': Style(
                            color: AppColors.foreground,
                            fontSize: FontSize(16),
                            lineHeight: const LineHeight(1.6),
                          ),
                          'a': Style(
                            color: AppColors.linkBlue,
                            textDecoration: TextDecoration.underline,
                          ),
                          'img': Style(
                            width: Width(100, Unit.percent),
                            height: Height.auto(),
                          ),
                        },
                        onLinkTap: (url, _, __) async {
                          if (url == null || url.isEmpty) return;
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),
                      const SwishBanner(compact: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
