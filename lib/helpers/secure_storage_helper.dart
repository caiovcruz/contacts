import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> write(String key, String? value) async {
    await _secureStorage.write(
      key: key,
      value: value,
    );
  }

  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> delete(String key) async {
    return await _secureStorage.delete(key: key);
  }
}
