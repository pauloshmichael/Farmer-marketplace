import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String operations
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Boolean operations
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  // Integer operations
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  // Double operations
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  // List operations
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  // JSON operations
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, json.encode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString);
    }
    return null;
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await _prefs.setString(key, json.encode(value));
  }

  List<Map<String, dynamic>> getJsonList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      final List<dynamic> list = json.decode(jsonString);
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Token operations
  Future<void> setAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? getAuthToken() {
    return _prefs.getString('auth_token');
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove('auth_token');
  }

  // User operations
  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    await setJson('current_user', user);
  }

  Map<String, dynamic>? getCurrentUser() {
    return getJson('current_user');
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove('current_user');
  }

  // Cart operations
  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    await setJsonList('cart', cartItems);
  }

  List<Map<String, dynamic>> getCart() {
    return getJsonList('cart');
  }

  Future<void> clearCart() async {
    await _prefs.remove('cart');
  }

  // Search history
  Future<void> addToSearchHistory(String query) async {
    List<String> history = getStringList('search_history');
    history.remove(query);
    history.insert(0, query);
    if (history.length > 20) {
      history = history.sublist(0, 20);
    }
    await setStringList('search_history', history);
  }

  List<String> getSearchHistory() {
    return getStringList('search_history');
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove('search_history');
  }

  // Recently viewed
  Future<void> addToRecentlyViewed(String productId) async {
    List<String> recentlyViewed = getStringList('recently_viewed');
    recentlyViewed.remove(productId);
    recentlyViewed.insert(0, productId);
    if (recentlyViewed.length > 20) {
      recentlyViewed = recentlyViewed.sublist(0, 20);
    }
    await setStringList('recently_viewed', recentlyViewed);
  }

  List<String> getRecentlyViewed() {
    return getStringList('recently_viewed');
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Remove specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}