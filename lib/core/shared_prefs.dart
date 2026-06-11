import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._();

  static late final SharedPreferences _prefs;

  // Initialize once during app startup
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- String Operations ---
  static String? getString(String key) => _prefs.getString(key);
  static Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  // --- Boolean Operations ---
  static bool getBool(String key) => _prefs.getBool(key) ?? false;
  static Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  // --- Clear / Delete ---
  static Future<bool> remove(String key) => _prefs.remove(key);
  static Future<bool> clear() => _prefs.clear();
}
