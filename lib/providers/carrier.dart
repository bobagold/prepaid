import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';
import 'package:prepaid/providers/carriers/demo.dart';
import 'package:prepaid/providers/carriers/lidl.dart';
import 'package:prepaid/providers/phones.dart';

import '../models/carrier_interface.dart';

final carrierProvider =
    StateNotifierProvider<CarrierProvider, List<CarrierInterface>>((ref) {
  return CarrierProvider(ref.read);
});

class CarrierProvider extends StateNotifier<List<CarrierInterface>> {
  CarrierProvider(this.read) : super([LidlNotifier(), DemoCarrier()]);

  final Reader read;

  CarrierInterface _carrier(Phone phone) {
    return state.firstWhere((element) => element.name == phone.carrier);
  }

  Future<bool> authorize(Phone phone, Credentials credentials) async {
    final updatedPhones = _carrier(phone).authorize(phone, credentials);
    return read(phonesProvider.notifier).mUpdate(updatedPhones);
  }

  void fetchBalance(Phone phone) async {
    final updatedPhones = _carrier(phone).fetchBalance(phone);
    read(phonesProvider.notifier).mUpdate(updatedPhones);
  }

  Future<void> refresh(List<Phone> phones) async {
    final phonesNotifier = read(phonesProvider.notifier);
    for (Phone phone in phones) {
      final updatedPhones = _carrier(phone).refresh(phone);
      phonesNotifier.mUpdate(updatedPhones);
    }
  }
}
