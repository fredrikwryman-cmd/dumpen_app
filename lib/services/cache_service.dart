/// # Lokal cache för Dumpen-appen
///
/// En enkel wrapper runt [SharedPreferences] som lagrar JSON-strängar för
/// artiklar och kategorier. Används som offline-fallback när nätverket inte
/// är tillgängligt.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _latestPostsKey = 'dumpen_latest_posts';
  static const String _categoriesKey = 'dumpen_categories';
  static const String _postPrefix = 'dumpen_post_';
  static const String _categoryPrefix = 'dumpen_category_';
  static const String _searchPrefix = 'dumpen_search_';
  static const String _consentKey = 'dumpen_consent_given';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // -------------------------------------------------------------------------
  // Samtycke vid första start
  // -------------------------------------------------------------------------

  static Future<bool> hasConsent() async {
    final prefs = await _instance;
    return prefs.getBool(_consentKey) ?? false;
  }

  static Future<void> setConsent(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_consentKey, value);
  }

  // -------------------------------------------------------------------------
  // Listor
  // -------------------------------------------------------------------------

  static Future<void> saveLatestPosts(List<Map<String, dynamic>> posts) async {
    final prefs = await _instance;
    await prefs.setString(_latestPostsKey, jsonEncode(posts));
  }

  static Future<List<Map<String, dynamic>>?> getLatestPosts() async {
    final prefs = await _instance;
    final raw = prefs.getString(_latestPostsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    final prefs = await _instance;
    await prefs.setString(_categoriesKey, jsonEncode(categories));
  }

  static Future<List<Map<String, dynamic>>?> getCategories() async {
    final prefs = await _instance;
    final raw = prefs.getString(_categoriesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Kategoriflöden
  // -------------------------------------------------------------------------

  static Future<void> saveCategoryPosts(
    int categoryId,
    List<Map<String, dynamic>> posts,
  ) async {
    final prefs = await _instance;
    await prefs.setString('$_categoryPrefix$categoryId', jsonEncode(posts));
  }

  static Future<List<Map<String, dynamic>>?> getCategoryPosts(int categoryId) async {
    final prefs = await _instance;
    final raw = prefs.getString('$_categoryPrefix$categoryId');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Sökresultat
  // -------------------------------------------------------------------------

  static Future<void> saveSearchResults(
    String query,
    List<Map<String, dynamic>> posts,
  ) async {
    final prefs = await _instance;
    await prefs.setString('$_searchPrefix$query', jsonEncode(posts));
  }

  static Future<List<Map<String, dynamic>>?> getSearchResults(String query) async {
    final prefs = await _instance;
    final raw = prefs.getString('$_searchPrefix$query');
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Enskilda inlägg
  // -------------------------------------------------------------------------

  static Future<void> savePost(int id, Map<String, dynamic> post) async {
    final prefs = await _instance;
    await prefs.setString('$_postPrefix$id', jsonEncode(post));
  }

  static Future<Map<String, dynamic>?> getPost(int id) async {
    final prefs = await _instance;
    final raw = prefs.getString('$_postPrefix$id');
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Rensa
  // -------------------------------------------------------------------------

  static Future<void> clear() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
