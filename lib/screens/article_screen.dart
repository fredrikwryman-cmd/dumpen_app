/// # Artikelvisning — professionell redesign
///
/// Hero-bild med gradient overlay, kategori-badge, titel, metadata,
/// HTML-brödtext med Noto Serif, inbäddade videor, Swish-banner.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' as html_parser;

import '../constants/app_colors.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import '../widgets/html_video_player.dart';
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

  List<String> _extractVideoUrls(String html) {
    final document = html_parser.parse(html);
    final videos = document.querySelectorAll('video');
    final urls = <String>[];
    for (final video in videos) {
      final directSrc = video.attributes['src'];
      if (directSrc != null && directSrc.isNotEmpty) {
        urls.add(directSrc);
        continue;
      }
      final source = video.querySelector('source');
      final sourceSrc = source?.attributes['src'];
      if (sourceSrc != null && sourceSrc.isNotEmpty) {
        urls.add(sourceSrc);
      }
    }
    return urls;
  }

  String _stripVideoTags(String html) {
    final document = html_parser.parse(html);
    document.querySelectorAll('video').forEach((e) => e.remove());
    return document.body?.innerHtml ?? html;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const _ShimmerHero(),
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.accentYellow),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null || _post == null) {
      return _buildError();
    }

    final post = _post!;
    final dateFormat = DateFormat('d MMMM y', 'sv_SE');
    final heroImage = post.featuredMedia?.full ?? post.featuredMedia?.feedUrl;
    final videoUrls = _extractVideoUrls(post.content);
    final articleHtml = _stripVideoTags(post.content);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            pinned: true,
            iconTheme: const IconThemeData(color: AppColors.foreground),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.foreground),
                tooltip: 'Dela artikel',
                onPressed: _shareArticle,
              ),
              IconButton(
                icon: const Icon(Icons.open_in_browser_outlined,
                    color: AppColors.foreground),
                tooltip: 'Öppna i webbläsare',
                onPressed: _openInBrowser,
              ),
            ],
          ),
          // Hero-bild med overlay
          if (heroImage != null && heroImage.isNotEmpty)
            SliverToBoxAdapter(child: _buildHeroImage(post, heroImage)),
          // Artikel-innehåll
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori-badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: post.categoryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      post.categoryLabel.toUpperCase(),
                      style: GoogleFonts.jost(
                        color: post.categoryTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Titel
                  Text(
                    post.title,
                    style: GoogleFonts.jost(
                      color: AppColors.foreground,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Metadata-rad
                  _buildMetadataRow(post, dateFormat),
                  const SizedBox(height: 24),
                  // Divider
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 24),
                  // Videor
                  if (videoUrls.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          videoUrls.length == 1 ? 'VIDEO' : 'VIDEOR',
                          style: GoogleFonts.jost(
                            color: AppColors.foreground,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...videoUrls.map(
                          (url) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: HtmlVideoPlayer(videoUrl: url),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  // Brödtext (HTML)
                  Html(
                    data: articleHtml,
                    style: {
                      'body': Style(
                        color: AppColors.foreground,
                        fontSize: FontSize(16),
                        lineHeight: const LineHeight(1.7),
                        fontFamily: GoogleFonts.notoSerif().fontFamily,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      'p': Style(
                        margin: Margins.only(bottom: 16),
                      ),
                      'a': Style(
                        color: AppColors.linkBlue,
                        textDecoration: TextDecoration.underline,
                      ),
                      'img': Style(
                        width: Width(100, Unit.percent),
                        height: Height.auto(),
                      ),
                      'h1': Style(
                        color: AppColors.foreground,
                        fontSize: FontSize(24),
                        fontWeight: FontWeight.w700,
                        margin: Margins.only(top: 24, bottom: 12),
                      ),
                      'h2': Style(
                        color: AppColors.foreground,
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.w700,
                        margin: Margins.only(top: 20, bottom: 10),
                      ),
                      'h3': Style(
                        color: AppColors.foreground,
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.w600,
                        margin: Margins.only(top: 16, bottom: 8),
                      ),
                      'blockquote': Style(
                        margin: Margins.symmetric(vertical: 16),
                        padding: HtmlPaddings.only(left: 16),
                        border: Border(
                          left: BorderSide(
                            color: AppColors.accentYellow,
                            width: 3,
                          ),
                        ),
                        color: AppColors.foregroundMuted,
                        fontStyle: FontStyle.italic,
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
                  const SizedBox(height: 24),
                  // Swish-banner
                  const SwishBanner(compact: true),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero-bild
  // ---------------------------------------------------------------------------

  Widget _buildHeroImage(WpPost post, String imageUrl) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppColors.surfaceLight),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.surfaceLight,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey, size: 48),
              ),
            ),
          ),
        ),
        // Gradient längst ner för smidig övergång
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 80,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.background.withValues(alpha: 0.8),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Metadata-rad
  // ---------------------------------------------------------------------------

  Widget _buildMetadataRow(WpPost post, DateFormat dateFormat) {
    return Row(
      children: [
        // Författare
        Icon(Icons.person_outline, size: 16, color: AppColors.foregroundDark),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            post.authorName,
            style: GoogleFonts.jost(
              color: AppColors.foregroundMuted,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Lästid
        Icon(Icons.access_time, size: 16, color: AppColors.foregroundDark),
        const SizedBox(width: 6),
        Text(
          post.readingTimeLabel,
          style: GoogleFonts.jost(
            color: AppColors.foregroundMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 16),
        // Datum
        Icon(Icons.calendar_today_outlined,
            size: 16, color: AppColors.foregroundDark),
        const SizedBox(width: 6),
        Text(
          dateFormat.format(post.date),
          style: GoogleFonts.jost(
            color: AppColors.foregroundMuted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Felmeddelande
  // ---------------------------------------------------------------------------

  Widget _buildError() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined,
                  color: AppColors.foregroundDark, size: 56),
              const SizedBox(height: 20),
              Text(
                'Kunde inte ladda artikeln.',
                style: GoogleFonts.jost(
                  color: AppColors.foreground,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kontrollera din internetanslutning.',
                textAlign: TextAlign.center,
                style: GoogleFonts.jost(
                  color: AppColors.foregroundMuted,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadPost,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Försök igen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shimmer-hero placeholder
// -----------------------------------------------------------------------------

class _ShimmerHero extends StatelessWidget {
  const _ShimmerHero();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(color: AppColors.surfaceLight),
    );
  }
}
