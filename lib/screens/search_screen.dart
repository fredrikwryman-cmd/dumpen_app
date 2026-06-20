/// # Sökskärm — professionell redesign
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import '../widgets/proxy_image.dart';
import 'article_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final WordPressApi _api = WordPressApi();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<WpPost> _results = [];
  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _hasSearched = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _api.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch({required bool refresh}) async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    if (refresh) {
      _focusNode.unfocus();
      _page = 1;
      _hasMore = true;
      _error = null;
    }

    if (_isLoading || _isLoadingMore) return;

    setState(() {
      if (refresh) {
        _isLoading = true;
        _hasSearched = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final page = refresh ? 1 : _page + 1;
      final posts = await _api.searchPosts(query, page: page);
      if (mounted) {
        setState(() {
          if (refresh) {
            _results
              ..clear()
              ..addAll(posts);
            _page = 1;
          } else {
            _results.addAll(posts);
            _page = page;
          }
          _hasMore = posts.length >= 10;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isLoading &&
        !_isLoadingMore) {
      _performSearch(refresh: false);
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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            style: GoogleFonts.jost(color: AppColors.foreground),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Sök på Dumpen...',
              hintStyle: GoogleFonts.jost(color: AppColors.foregroundDark),
              border: InputBorder.none,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.foregroundDark),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _results = [];
                          _hasSearched = false;
                          _hasMore = true;
                          _error = null;
                        });
                      },
                    )
                  : null,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(refresh: true),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.foreground),
            tooltip: 'Sök',
            onPressed: () => _performSearch(refresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentYellow,
        backgroundColor: AppColors.surface,
        onRefresh: () => _performSearch(refresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => const _ShimmerListItem(),
      );
    }

    if (_error != null && _results.isEmpty) {
      return _buildError();
    }

    if (!_hasSearched) {
      return _buildEmpty(
        icon: Icons.search,
        message: 'Skriv något för att börja söka',
      );
    }

    if (_results.isEmpty) {
      return _buildEmpty(
        icon: Icons.search_off,
        message: 'Inga resultat hittades för "${_controller.text.trim()}"',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _results.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accentYellow),
            ),
          );
        }
        return _SearchResultItem(
          post: _results[index],
          onTap: () => _openArticle(_results[index]),
        );
      },
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
              'Något gick fel vid sökningen',
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(
                color: AppColors.foreground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kontrollera din internetanslutning och försök igen.',
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(
                color: AppColors.foregroundMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _performSearch(refresh: true),
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

  Widget _buildEmpty({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.foregroundDark, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(color: AppColors.foregroundMuted),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sökresultat-kort
// -----------------------------------------------------------------------------

class _SearchResultItem extends StatelessWidget {
  final WpPost post;
  final VoidCallback onTap;

  const _SearchResultItem({required this.post, required this.onTap});

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
                  width: 100,
                  height: 75,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? ProxyImage(
                            // ignore: unnecessary_non_null_assertion
                            imageUrl: imageUrl!,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(10),
                          )
                        : Container(
                            color: AppColors.surfaceLight,
                            child: const Icon(Icons.image,
                                color: Colors.grey, size: 24),
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
                        style: GoogleFonts.jost(
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
                          style: GoogleFonts.notoSerif(
                            color: AppColors.foregroundMuted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        dateFormat.format(post.date),
                        style: GoogleFonts.jost(
                          color: AppColors.foregroundDark,
                          fontSize: 11,
                        ),
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
                width: 100,
                height: 75,
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
                    Container(width: 120, height: 12, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 60, height: 10, color: Colors.white),
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
