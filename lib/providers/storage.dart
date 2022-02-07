import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/src/secure_storage/secure_storage_repository.dart';

final storageProvider =
    StateNotifierProvider<StorageNotifier, SecureStorageRepository>(
        (ref) => StorageNotifier());

class StorageNotifier extends StateNotifier<SecureStorageRepository> {
  StorageNotifier() : super(SecureStorageRepository());
}
