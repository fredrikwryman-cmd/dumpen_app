/// # Filtrerad feed för en vald kategori — professionell redesign
///
/// Hero-header med kategorifärg, sedan artikellista i listläge.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import '../widgets/proxy_image.dart';
import 'article_screen.dart';

class CategoryFeedScreen extends StatefulWidget {
  final WpCategory category;

  const CategoryFeedScreen({super.key, required this.category});

  @override
  State<CategoryFeedScreen> createState() => _CategoryFeedScreenState();
}

class _CategoryFeedScreenState extends State<CategoryFeedScreen> {
  final WordPressApi _api = WordPressApi();
  final ScrollController _scrollController = ScrollController();

  final List<WpPost> _posts = [];
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
      if (refresh) {
        _isLoading = true;
        _error = null;
      }
    });

    try {
      final page = refresh ? 1 : _page + 1;
      final posts = await _api.fetchPostsByCategory(
        widget.category.id,
        page: page,
      );
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

  void _openArticle(WpPost post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleScreen(postId: post.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accentYellow,
        backgroundColor: AppColors.surface,
        onRefresh: () => _loadPosts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Hero-header med kategorifärg
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: widget.category.color,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              iconTheme: const IconThemeData(color: Colors.white),
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.category.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 16,
                  ),
                ),
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        widget.category.color,
                        widget.category.color.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_posts.isNotEmpty)
              SliverToBoxAdapter(child: _buildSectionHeader()),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: widget.category.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_posts.length} INLÄGG',
            style: TextStyle(
              fontFamily: 'sans-serif',
              color: AppColors.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Container(width: 40, height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  Widget _buildBody() {
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
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Inga inlägg hittades i den här kategorien.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.foregroundMuted),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= _posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accentYellow),
              ),
            );
          }
          return _ArticleListItem(
            post: _posts[index],
            onTap: () => _openArticle(_posts[index]),
          );
        },
        childCount: _posts.length + (_hasMore ? 1 : 0),
      ),
    );
  }

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
              style: TextStyle(
                fontFamily: 'sans-serif',
                color: AppColors.foreground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kontrollera din internetanslutning och försök igen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'sans-serif',
                color: AppColors.foregroundMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _loadPosts(refresh: true),
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
    );
  }
}

// -----------------------------------------------------------------------------
// Artikelkort i listläge
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  height: 82,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageUrl != null && imageUrl.isNotEmpty
                            ? ProxyImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                borderRadius: BorderRadius.circular(10),
                                placeholder: Shimmer.fromColors(
                                  baseColor: AppColors.shimmerBackground,
                                  highlightColor: AppColors.shimmerHighlight,
                                  child: Container(color: Colors.white),
                                ),
                              )
                            : Container(
                                color: AppColors.surfaceLight,
                                child: const Icon(Icons.image,
                                    color: Colors.white24, size: 28),
                              ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: post.categoryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              post.categoryLabel.toUpperCase(),
                              style: TextStyle(
                                color: post.categoryTextColor,
                                fontSize: 7,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          color: AppColors.foreground,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      if (post.plainExcerpt.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          post.plainExcerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'serif',
                            color: AppColors.foregroundMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 11, color: AppColors.foregroundDark),
                          const SizedBox(width: 4),
                          Text(
                            post.readingTimeLabel,
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              color: AppColors.foregroundDark,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            dateFormat.format(post.date),
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              color: AppColors.foregroundDark,
                              fontSize: 10,
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

class _ShimmerListItem extends StatelessWidget {
  const _ShimmerListItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBackground,
        highlightColor: AppColors.shimmerHighlight,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        height: 14,
                        color: Colors.white),
                    const SizedBox(height: 8),
                    Container(
                        width: 120,
                        height: 12,
                        color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 10, color: Colors.white),
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
