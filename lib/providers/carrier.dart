import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';
import 'package:prepaid/providers/carriers/demo.dart';
import 'package:prepaid/providers/carriers/lidl.dart';
import 'package:prepaid/providers/phones.dart';

import '../models/carrier_interface.dart';

final carrierProvider = StateNotifierProvider<CarrierProvider, List<CarrierInterface>>((ref) {
  return CarrierProvider(ref.read);
});

class CarrierProvider extends StateNotifier<List<CarrierInterface>> {
  CarrierProvider(this.read) : super([LidlNotifier(), DemoCarrier()]);

  final PhonesNotifier Function(ProviderListenable<PhonesNotifier>) read;

  CarrierInterface _carrier(Phone phone) {
    return state.firstWhere((element) => element.name == phone.carrier);
  }

  Future<bool> authorize(Phone phone, Credentials credentials) async {
    final updatedPhones = _carrier(phone).authorize(phone, credentials);
    final success = Completer<bool>();
    updatedPhones.listen((updatedPhone) {
      if (!success.isCompleted) {
        success.complete(true);
      }
      read(phonesProvider.notifier).update(updatedPhone);
    }, onDone: () {
      if (!success.isCompleted) {
        success.complete(false);
      }
    });
    return success.future;
  }

  void fetchBalance(Phone phone) async {
    final updatedPhones = _carrier(phone).fetchBalance(phone);
    read(phonesProvider.notifier).mUpdate(updatedPhones);
  }

  Future<void> refresh(List<Phone> phones) async {
    final phonesNotifier = read(phonesProvider.notifier);
    for (Phone phone in phones) {
      final updatedPhones = _carrier(phone).refresh(phone);
      await phonesNotifier.mUpdate(updatedPhones);
    }
  }

  Future<void> fetchDetails(Phone phone) async {
    final phonesNotifier = read(phonesProvider.notifier);
    final updatedPhones = _carrier(phone).fetchDetails(phone);
    phonesNotifier.mUpdate(updatedPhones);
  }

  Future<bool> book(Phone phone, PlanOption option) async {
    final updatedPhones = _carrier(phone).book(phone, option);
    return read(phonesProvider.notifier).mUpdate(updatedPhones);
  }
}
