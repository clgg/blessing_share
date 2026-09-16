abstract interface class AppStorage {
  Future<Map<String, Object?>> readJson(String key);

  Future<void> writeJson(String key, Map<String, Object?> value);
}
