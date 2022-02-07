import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageRepository {
  final FlutterSecureStorage storage;

  SecureStorageRepository()
      : storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  Future<String?> read(String key) => storage.read(key: key);

  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);
}
