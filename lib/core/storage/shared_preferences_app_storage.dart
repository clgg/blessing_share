import 'dart:convert';

import 'package:blessing_share/core/storage/app_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesAppStorage implements AppStorage {
  SharedPreferencesAppStorage(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPreferencesAppStorage> create() async {
    return SharedPreferencesAppStorage(await SharedPreferences.getInstance());
  }

  @override
  Future<Map<String, Object?>> readJson(String key) async {
    final source = _preferences.getString(key);
    if (source == null) return {'version': 1};
    try {
      final decoded = jsonDecode(source);
      if (decoded is Map) return decoded.cast<String, Object?>();
    } catch (_) {
      // Corrupt demo state must not prevent the app from opening.
    }
    return {'version': 1};
  }

  @override
  Future<void> writeJson(String key, Map<String, Object?> value) async {
    await _preferences.setString(key, jsonEncode(value));
  }
}
