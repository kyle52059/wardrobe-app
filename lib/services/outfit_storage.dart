import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/outfit.dart';

class OutfitStorage {
  static const _key = 'saved_outfits';

  static Future<List<Outfit>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    return (jsonDecode(data) as List).map((e) => Outfit.fromJson(e)).toList();
  }

  static Future<void> save(Outfit outfit) async {
    final list = await loadAll();
    list.insert(0, outfit);
    await _persist(list);
  }

  static Future<void> delete(String id) async {
    final list = await loadAll();
    list.removeWhere((e) => e.id == id);
    await _persist(list);
  }

  static Future<void> _persist(List<Outfit> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
