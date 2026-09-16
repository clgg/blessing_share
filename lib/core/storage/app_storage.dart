abstract interface class AppStorage {
  Future<Map<String, Object?>> readJson(String key);

  Future<void> writeJson(String key, Map<String, Object?> value);
}

class MemoryAppStorage implements AppStorage {
  MemoryAppStorage([Map<String, Map<String, Object?>>? seed])
      : _values = {...?seed};

  final Map<String, Map<String, Object?>> _values;

  @override
  Future<Map<String, Object?>> readJson(String key) async {
    return Map<String, Object?>.of(_values[key] ?? const {'version': 1});
  }

  @override
  Future<void> writeJson(String key, Map<String, Object?> value) async {
    _values[key] = Map<String, Object?>.of(value);
  }
}
