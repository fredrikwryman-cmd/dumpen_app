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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.foreground),
        title: Text(
          widget.category.name.toUpperCase(),
          style: const TextStyle(
            color: AppColors.foreground,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            color: widget.category.color,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.foreground,
        backgroundColor: AppColors.surface,
        onRefresh: () => _loadPosts(refresh: true),
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
                    padding: const EdgeInsets.only(bottom: 24, top: 8),
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
