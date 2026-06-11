import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  // Static helper to quickly retrieve the service instance
  static StorageService get to => Get.find<StorageService>();

  late final SharedPreferences _prefs;

  // Initialize SharedPreferences once
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // --- String Operations ---
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  // --- Boolean Operations ---
  bool getBool(String key) => _prefs.getBool(key) ?? false;
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  // --- Clear / Delete ---
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();
}
