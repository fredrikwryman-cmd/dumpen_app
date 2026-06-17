/// # Sökskärm
///
/// Låter användaren söka bland Dumpens artiklar via WordPress REST API.
/// Visar resultat i samma stil som feeden med pull-to-refresh,
/// oändlig scroll och ett tydligt tomt tillstånd.
library;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import '../widgets/article_card.dart';
import '../widgets/shimmer_card.dart';
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
      MaterialPageRoute(
        builder: (_) => ArticleScreen(postId: post.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            style: const TextStyle(color: AppColors.foreground),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Sök på Dumpen...',
              hintStyle: TextStyle(color: AppColors.grey500),
              border: InputBorder.none,
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
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
        color: AppColors.foreground,
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
        itemBuilder: (_, __) => const ShimmerCard(),
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
              child: CircularProgressIndicator(color: AppColors.foreground),
            ),
          );
        }
        final post = _results[index];
        return ArticleCard(
          post: post,
          onTap: () => _openArticle(post),
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
            Icon(Icons.cloud_off_outlined, color: AppColors.grey500, size: 56),
            const SizedBox(height: 20),
            Text(
              'Något gick fel vid sökningen',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kontrollera din internetanslutning och försök igen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.foregroundMuted, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _performSearch(refresh: true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
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
          Icon(icon, color: AppColors.grey600, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.foregroundMuted),
          ),
        ],
      ),
    );
  }
}
