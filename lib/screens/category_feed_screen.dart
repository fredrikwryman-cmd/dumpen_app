/// # Filtrerad feed för en vald kategori
///
/// Återanvänder samma utseende som hemskärmen men visar endast inlägg från
/// den valda kategorin.
library;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import '../widgets/article_card.dart';
import '../widgets/shimmer_card.dart';
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
      _isLoading = true;
      if (refresh) _error = null;
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
      MaterialPageRoute(
        builder: (_) => ArticleScreen(postId: post.id),
      ),
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
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: AppColors.background.withValues(alpha: 0.95),
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.foreground),
              title: Text(
                widget.category.name.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 18,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: Container(
                  height: 3,
                  color: widget.category.color,
                ),
              ),
            ),
            _buildBody(),
          ],
        ),
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
              'Kontrollera din internetanslutning och försök igen.',
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
