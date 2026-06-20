/// # Kategorilista — professionell redesign
///
/// Sida med alla kategorier i ett rutnät. Sökfiltrering överst.
library;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/post.dart';
import '../services/wordpress_api.dart';
import 'category_feed_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final WordPressApi _api = WordPressApi();
  final TextEditingController _searchController = TextEditingController();

  List<WpCategory> _categories = [];
  List<WpCategory> _filtered = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _api.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _api.fetchCategories();
      categories.sort((a, b) => b.count.compareTo(a.count));
      if (mounted) {
        setState(() {
          _categories = categories;
          _filtered = categories;
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

  void _onSearchChanged(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filtered = _categories
          .where((c) => c.name.toLowerCase().contains(lower))
          .toList();
    });
  }

  void _openCategory(WpCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryFeedScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              'KATEGORIER',
              style: TextStyle(
                fontFamily: 'sans-serif',
                color: AppColors.foreground,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 18,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(fontFamily: 'sans-serif', color: AppColors.foreground),
                decoration: InputDecoration(
                  hintText: 'Sök kategori...',
                  hintStyle: TextStyle(fontFamily: 'sans-serif', color: AppColors.foregroundDark),
                  prefixIcon: const Icon(Icons.search, color: AppColors.foregroundDark),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: AppColors.accentYellow)),
      );
    }

    if (_error != null && _categories.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildError(),
      );
    }

    if (_filtered.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmpty(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = _filtered[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryCard(
                category: category,
                onTap: () => _openCategory(category),
              ),
            );
          },
          childCount: _filtered.length,
        ),
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
              'Kunde inte ladda kategorier',
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
              onPressed: _loadCategories,
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, color: AppColors.foregroundDark, size: 56),
          const SizedBox(height: 16),
          Text(
            'Inga kategorier matchade sökningen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'sans-serif', color: AppColors.foregroundMuted),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final WpCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              // Kategorifärg — vertikal accentlinje
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: AppColors.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.count} inlägg',
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: AppColors.foregroundDark,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.foregroundDark,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
