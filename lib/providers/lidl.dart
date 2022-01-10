import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';

// todo move to plugin
final lidlProvider = StateNotifierProvider<LidlNotifier, void>((ref) {
  return LidlNotifier();
});

class LidlNotifier extends StateNotifier<void> {
  LidlNotifier() : super([]);
  Future<bool> authorize(Credentials credentials) async {
    await Future.delayed(const Duration(seconds: 10));
    return true;
  }
}
