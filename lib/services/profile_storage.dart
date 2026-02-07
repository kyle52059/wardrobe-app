import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileStorage {
  static const _key = 'user_profile';

  static Future<UserProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    return data != null ? UserProfile.fromJson(jsonDecode(data)) : null;
  }

  static Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }
}
