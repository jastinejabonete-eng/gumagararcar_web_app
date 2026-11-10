import 'package:shared_preferences/shared_preferences.dart';

/// Persists the storefront's single, versioned JSON snapshot.
abstract class StoreStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class SharedPreferencesStoreStorage implements StoreStorage {
  static const String storageKey = 'gumagararcar.store.v1';

  // Lazy creation lets initialize() surface missing-plugin/storage failures.
  late final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> read() async => _preferences.getString(storageKey);

  @override
  Future<void> write(String value) async => _preferences.setString(storageKey, value);
}

class MemoryStoreStorage implements StoreStorage {
  MemoryStoreStorage([String? initialValue]) : _value = initialValue;

  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async => _value = value;
}
