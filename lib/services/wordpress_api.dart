/// # WordPress API-klient för Dumpen.se
///
/// Hanterar alla anrop mot Dumpens WordPress REST API (se [AppConstants.apiBaseUrl]),
/// inklusive paginering, timeout, felhantering och offline-cache via [CacheService].
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../constants/app_constants.dart';
import '../models/post.dart';
import 'cache_service.dart';

class WordPressApi {
  static final String _baseUrl = AppConfig.apiBaseUrl;
  static const String _embed = 'author,wp:featuredmedia';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  WordPressApi({http.Client? client}) : _client = client ?? http.Client();

  // -------------------------------------------------------------------------
  // Hjälpare för anrop
  // -------------------------------------------------------------------------

  Future<List<dynamic>> _getList(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client
        .get(uri, headers: {'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 DumpenApp/1.0'})
        .timeout(_timeout, onTimeout: () => throw TimeoutException('Timeout'));

    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Förväntade en lista från API:t');
    }
    return decoded;
  }

  Future<Map<String, dynamic>> _getObject(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client
        .get(uri, headers: {'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 DumpenApp/1.0'})
        .timeout(_timeout, onTimeout: () => throw TimeoutException('Timeout'));

    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Förväntade ett objekt från API:t');
    }
    return decoded;
  }

  // -------------------------------------------------------------------------
  // Senaste inlägg
  // -------------------------------------------------------------------------

  Future<List<WpPost>> fetchLatestPosts({int page = 1, int perPage = 10}) async {
    try {
      final raw = await _getList(
        '/posts?_embed=$_embed&page=$page&per_page=$perPage',
      );
      final posts = raw.cast<Map<String, dynamic>>().map(WpPost.fromJson).toList();
      if (page == 1) {
        await CacheService.saveLatestPosts(
          posts.map((p) => p.toJson()).toList(),
        );
      }
      return posts;
    } on SocketException catch (_) {
      if (page == 1) {
        final cached = await CacheService.getLatestPosts();
        if (cached != null && cached.isNotEmpty) {
          return cached.map(WpPost.fromJson).toList();
        }
      }
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Inlägg per kategori
  // -------------------------------------------------------------------------

  Future<List<WpPost>> fetchPostsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final raw = await _getList(
        '/posts?categories=$categoryId&_embed=$_embed&page=$page&per_page=$perPage',
      );
      final posts =
          raw.cast<Map<String, dynamic>>().map(WpPost.fromJson).toList();
      if (page == 1) {
        await CacheService.saveCategoryPosts(
          categoryId,
          posts.map((p) => p.toJson()).toList(),
        );
      }
      return posts;
    } on SocketException catch (_) {
      if (page == 1) {
        final cached = await CacheService.getCategoryPosts(categoryId);
        if (cached != null && cached.isNotEmpty) {
          return cached.map(WpPost.fromJson).toList();
        }
      }
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Specifikt inlägg
  // -------------------------------------------------------------------------

  Future<WpPost> fetchPost(int id) async {
    try {
      final raw = await _getObject('/posts/$id?_embed=$_embed');
      final post = WpPost.fromJson(raw);
      await CacheService.savePost(id, post.toJson());
      return post;
    } on SocketException catch (_) {
      final cached = await CacheService.getPost(id);
      if (cached != null) {
        return WpPost.fromJson(cached);
      }
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Sök
  // -------------------------------------------------------------------------

  Future<List<WpPost>> searchPosts(
    String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    final encoded = Uri.encodeComponent(query);
    try {
      final raw = await _getList(
        '/posts?search=$encoded&_embed=$_embed&page=$page&per_page=$perPage',
      );
      final posts =
          raw.cast<Map<String, dynamic>>().map(WpPost.fromJson).toList();
      if (page == 1) {
        await CacheService.saveSearchResults(
          query,
          posts.map((p) => p.toJson()).toList(),
        );
      }
      return posts;
    } on SocketException catch (_) {
      if (page == 1) {
        final cached = await CacheService.getSearchResults(query);
        if (cached != null && cached.isNotEmpty) {
          return cached.map(WpPost.fromJson).toList();
        }
      }
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Kategorier
  // -------------------------------------------------------------------------

  Future<List<WpCategory>> fetchCategories() async {
    try {
      final raw = await _getList('/categories?per_page=100');
      final categories =
          raw.cast<Map<String, dynamic>>().map(WpCategory.fromJson).toList();
      await CacheService.saveCategories(
        categories.map((c) => c.toJson()).toList(),
      );
      return categories;
    } on SocketException catch (_) {
      final cached = await CacheService.getCategories();
      if (cached != null && cached.isNotEmpty) {
        return cached.map(WpCategory.fromJson).toList();
      }
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
