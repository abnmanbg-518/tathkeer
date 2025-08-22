import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveList(String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items);
    await prefs.setString(key, encoded);
  }

  static Future<List<Map<String, dynamic>>> loadList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(key);
    if (s == null || s.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(s);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
