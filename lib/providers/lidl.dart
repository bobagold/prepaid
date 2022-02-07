import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';
import 'package:prepaid/providers/phones.dart';

// todo move to plugin
final lidlProvider = StateNotifierProvider<LidlNotifier, void>((ref) {
  return LidlNotifier(ref.read);
});

class LidlNotifier extends StateNotifier<void> {
  LidlNotifier(this.read) : super([]);

  final Reader read;

  Future<bool> authorize(Phone phone, Credentials credentials) async {
    await Future.delayed(const Duration(seconds: 3));
    final phones = read(phonesProvider.notifier);
    var fakeAuth = Auth('xxx', DateTime.now().add(const Duration(hours: 1)));
    var updatedPhone = Phone(
      phone.phone,
      auth: fakeAuth,
    );
    phones.update(updatedPhone);
    fetchBalance(updatedPhone);
    return true;
  }

  void fetchBalance(Phone phone) async {
    final phones = read(phonesProvider.notifier);
    await Future.delayed(const Duration(seconds: 1));
    phones.update(Phone(
      phone.phone,
      auth: phone.auth,
      balance: Money(50),
      plan: 'XXL',
      limits: Limits(0, 10 ^ 9, 0, 100, 0, 100),
    ));
  }
}
