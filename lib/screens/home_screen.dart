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
      body: RefreshIndicator(
        color: AppColors.foreground,
        backgroundColor: AppColors.surface,
        onRefresh: () => _loadPosts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Appbar med logo
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: AppColors.background.withValues(alpha: 0.95),
              elevation: 0,
              centerTitle: false,
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'D',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DUMPEN',
                    style: TextStyle(
                      color: AppColors.foreground,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.foreground),
                  tooltip: 'Sök',
                  onPressed: _openSearch,
                ),
                const SizedBox(width: 8),
              ],
            ),
            // Hero / intro
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Senaste från Dumpen',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Barnrättsrörelsen som exponerar barnfridsbrott.',
                      style: TextStyle(
                        color: AppColors.foregroundMuted,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Kategorifilter
            SliverToBoxAdapter(
              child: Container(
                height: 56,
                color: AppColors.background,
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _topFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _topFilters[index];
                    final category = WpCategory(
                      id: filter['id'] as int,
                      name: filter['name'] as String,
                      count: 0,
                      color: filter['id'] == 0
                          ? AppColors.primaryGreen
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
            ),
            // Feed
            _buildFeed(),
          ],
        ),
      ),
    );
  }

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
          (_, __) => const ShimmerCard(),
          childCount: 5,
        ),
      );
    }

    if (_posts.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Inga inlägg hittades.',
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
            Icon(Icons.cloud_off_outlined, color: AppColors.grey500, size: 56),
            const SizedBox(height: 20),
            Text(
              'Kunde inte ladda inlägg',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kontrollera att du har internetanslutning. '
              'Observera att webb-versionen kan blockeras av CORS vid körning från localhost.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.foregroundMuted, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _loadPosts(refresh: true),
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
}
