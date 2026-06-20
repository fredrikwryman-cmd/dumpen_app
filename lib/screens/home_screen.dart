/// # Hemskärm — professionell redesign
///
/// Hero-banner med featured-post (stor bild + overlay), sedan artikelista
/// i listläge med bild till vänster och text till höger (som dumpen.se).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import '../widgets/pike_header.dart';
import '../widgets/proxy_image.dart';
import 'article_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WordPressApi _api = WordPressApi();
  final ScrollController _scrollController = ScrollController();

  final List<WpPost> _posts = [];
  int _selectedCategoryId = 0;
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPosts(refresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _api.dispose();
    super.dispose();
  }

  Future<void> _loadPosts({required bool refresh}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      if (refresh) _error = null;
    });

    try {
      final page = refresh ? 1 : _page + 1;
      final posts = _selectedCategoryId == 0
          ? await _api.fetchLatestPosts(page: page)
          : await _api.fetchPostsByCategory(_selectedCategoryId, page: page);

      setState(() {
        if (refresh) {
          _posts
            ..clear()
            ..addAll(posts);
          _page = 1;
        } else {
          _posts.addAll(posts);
          _page = page;
        }
        _hasMore = posts.length >= 10;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isLoading) {
      _loadPosts(refresh: false);
    }
  }

  void _onCategorySelected(int id) {
    if (_selectedCategoryId == id) return;
    setState(() => _selectedCategoryId = id);
    _loadPosts(refresh: true);
  }

  void _openArticle(WpPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleScreen(postId: post.id)),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.foreground,
        backgroundColor: AppColors.surface,
        onRefresh: () => _loadPosts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: PikeHeader(onSearch: _openSearch),
            ),
            if (_posts.isNotEmpty) ...[
              _buildHeroBanner(),
              _buildCategoryFilter(),
              _buildSectionHeader(),
            ],
            _buildFeed(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero banner — stor featured-post med overlay
  // ---------------------------------------------------------------------------

  Widget _buildHeroBanner() {
    final hero = _posts.first;
    final imageUrl = hero.featuredMedia?.full ?? hero.featuredMedia?.feedUrl;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shadowColor: Colors.black12,
          child: InkWell(
            onTap: () => _openArticle(hero),
            child: Stack(
              children: [
                // Bakgrundsbild
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? ProxyImage(
                          // ignore: unnecessary_non_null_assertion
                          imageUrl: imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: Shimmer.fromColors(
                            baseColor: AppColors.shimmerBackground,
                            highlightColor: AppColors.shimmerHighlight,
                            child: Container(color: Colors.grey.shade200),
                          ),
                          errorWidget: Container(
                            color: AppColors.surfaceLight,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey, size: 48),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceLight,
                          child: const Icon(Icons.image,
                              color: Colors.grey, size: 48),
                        ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                // Text overlay
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori-badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: hero.categoryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hero.categoryLabel.toUpperCase(),
                          style: GoogleFonts.jost(
                            color: hero.categoryTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Titel
                      Text(
                        hero.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jost(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Metadata
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 14, color: Colors.white.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            hero.readingTimeLabel,
                            style: GoogleFonts.jost(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.calendar_today_outlined,
                              size: 14, color: Colors.white.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('d MMM y', 'sv_SE').format(hero.date),
                            style: GoogleFonts.jost(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Kategorifilter
  // ---------------------------------------------------------------------------

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: Container(
        height: 52,
        color: AppColors.background,
        padding: const EdgeInsets.only(bottom: 4),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: AppConstants.topCategoryFilters.length,
          itemBuilder: (context, index) {
            final filter = AppConstants.topCategoryFilters[index];
            final id = filter['id'] as int;
            final name = filter['name'] as String;
            final colorIdx = filter['colorIdx'] as int;
            final color = id == 0 ? AppColors.accentYellow : AppColors.categoryColor(colorIdx);
            final selected = _selectedCategoryId == id;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: selected ? color : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    elevation: selected ? 2 : 0,
                    shadowColor: Colors.black12,
                    child: InkWell(
                      onTap: () => _onCategorySelected(id),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? Colors.transparent : AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          name,
                          style: GoogleFonts.jost(
                            color: selected
                                ? AppColors.categoryTextColor(colorIdx)
                                : AppColors.foreground,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sektionrubrik
  // ---------------------------------------------------------------------------

  Widget _buildSectionHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _selectedCategoryId == 0 ? 'SENASTE INLÄGG' : 'INLÄGG',
              style: GoogleFonts.jost(
                color: AppColors.foreground,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            Expanded(
              flex: 2,
              child: Container(
                height: 1,
                color: AppColors.border,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Feed-lista
  // ---------------------------------------------------------------------------

  Widget _buildFeed() {
    if (_error != null && _posts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildError(),
      );
    }

    if (_posts.isEmpty && _isLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const _ShimmerListItem(),
          childCount: 5,
        ),
      );
    }

    if (_posts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Inga inlägg hittades.',
            style: GoogleFonts.jost(color: AppColors.foregroundMuted),
          ),
        ),
      );
    }

    // Hoppa över hero-post (index 0) i listan
    final listPosts = _posts.length > 1 ? _posts.sublist(1) : <WpPost>[];

    if (listPosts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= listPosts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accentYellow),
              ),
            );
          }
          return _ArticleListItem(
            post: listPosts[index],
            onTap: () => _openArticle(listPosts[index]),
          );
        },
        childCount: listPosts.length + (_hasMore ? 1 : 0),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Felmeddelande
  // ---------------------------------------------------------------------------

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                color: AppColors.foregroundDark, size: 56),
            const SizedBox(height: 20),
            Text(
              'Kunde inte ladda inlägg',
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(
                color: AppColors.foreground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kontrollera att du har internetanslutning.',
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(
                color: AppColors.foregroundMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _loadPosts(refresh: true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.foreground,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text('Försök igen', style: GoogleFonts.jost()),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Artikelkort i listläge — bild vänster, text höger (dumpen.se stil)
// -----------------------------------------------------------------------------

class _ArticleListItem extends StatelessWidget {
  final WpPost post;
  final VoidCallback onTap;

  const _ArticleListItem({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM y', 'sv_SE');
    final imageUrl = post.featuredMedia?.feedUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bild (vänster)
                SizedBox(
                  width: 120,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageUrl != null && imageUrl.isNotEmpty
                            ? ProxyImage(
                                // ignore: unnecessary_non_null_assertion
                                imageUrl: imageUrl!,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(10),
                                placeholder: Shimmer.fromColors(
                                  baseColor: AppColors.shimmerBackground,
                                  highlightColor: AppColors.shimmerHighlight,
                                  child: Container(color: Colors.grey.shade200),
                                ),
                                errorWidget: Container(
                                  color: AppColors.surfaceLight,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey, size: 32),
                                ),
                              )
                            : Container(
                                color: AppColors.surfaceLight,
                                child: const Icon(Icons.image,
                                    color: Colors.grey, size: 32),
                              ),
                            // Kategori-badge över bilden
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: post.categoryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.categoryLabel.toUpperCase(),
                              style: GoogleFonts.jost(
                                color: post.categoryTextColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Text (höger)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titel
                      Text(
                        post.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jost(
                          color: AppColors.foreground,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Ingress (om finns)
                      if (post.plainExcerpt.isNotEmpty) ...[
                        Text(
                          post.plainExcerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSerif(
                            color: AppColors.foregroundMuted,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Metadata-rad
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 12, color: AppColors.foregroundDark),
                          const SizedBox(width: 4),
                          Text(
                            post.readingTimeLabel,
                            style: GoogleFonts.jost(
                              color: AppColors.foregroundDark,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.calendar_today_outlined,
                              size: 12, color: AppColors.foregroundDark),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(post.date),
                            style: GoogleFonts.jost(
                              color: AppColors.foregroundDark,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shimmer-laddningsindikator för listläge
// -----------------------------------------------------------------------------

class _ShimmerListItem extends StatelessWidget {
  const _ShimmerListItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBackground,
        highlightColor: AppColors.shimmerHighlight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 140,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
