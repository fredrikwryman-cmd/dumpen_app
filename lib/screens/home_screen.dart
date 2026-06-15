/// # Hemskärm / nyhetsfeed
///
/// Visar senaste inlägg från Dumpen med kategorifilter, pull-to-refresh
/// och oändlig scroll. Navigerar till artikel- och sökskärm.
library;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/shimmer_card.dart';
import 'article_screen.dart';
import 'search_screen.dart';

/// Kategorier som visas i filterraden överst på hemskärmen.
const List<Map<String, dynamic>> _topFilters = [
  {'id': 0, 'name': 'Senaste'},
  {'id': 11, 'name': 'Hall of Shame'},
  {'id': 6, 'name': 'Krönika'},
  {'id': 26, 'name': 'Videos'},
  {'id': 29, 'name': 'Rättsbevakning'},
];

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
      MaterialPageRoute(
        builder: (_) => ArticleScreen(postId: post.id),
      ),
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'DUMPEN',
          style: TextStyle(
            color: AppColors.foreground,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.foreground),
            tooltip: 'Sök',
            onPressed: _openSearch,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.foreground,
        backgroundColor: AppColors.surface,
        onRefresh: () => _loadPosts(refresh: true),
        child: Column(
          children: [
            // Kategorifilter
            Container(
              height: 52,
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _topFilters.length,
                itemBuilder: (context, index) {
                  final filter = _topFilters[index];
                  final category = WpCategory(
                    id: filter['id'] as int,
                    name: filter['name'] as String,
                    count: 0,
                    color: filter['id'] == 0
                        ? AppColors.foreground
                        : AppColors.mutedGrey,
                  );
                  return CategoryChip(
                    category: category,
                    selected: _selectedCategoryId == filter['id'],
                    onTap: () => _onCategorySelected(filter['id'] as int),
                  );
                },
              ),
            ),
            // Feed
            Expanded(
              child: _error != null && _posts.isEmpty
                  ? _buildError()
                  : _posts.isEmpty && _isLoading
                      ? ListView.builder(
                          itemCount: 5,
                          itemBuilder: (_, __) => const ShimmerCard(),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: _posts.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _posts.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.foreground,
                                  ),
                                ),
                              );
                            }
                            final post = _posts[index];
                            return ArticleCard(
                              post: post,
                              onTap: () => _openArticle(post),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            Text(
              'Kunde inte ladda inlägg.\nKontrollera din internetanslutning.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey400),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadPosts(refresh: true),
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
}
