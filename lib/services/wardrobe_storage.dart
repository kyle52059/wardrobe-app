import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clothing_item.dart';

class WardrobeStorage {
  static const _key = 'wardrobe_items';

  static Future<List<ClothingItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => ClothingItem.fromJson(e)).toList();
  }

  static Future<void> saveItems(List<ClothingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<void> addItem(ClothingItem item) async {
    final items = await loadItems();
    items.add(item);
    await saveItems(items);
  }

  static Future<void> deleteItem(String id) async {
    final items = await loadItems();
    items.removeWhere((e) => e.id == id);
    await saveItems(items);
  }
}
