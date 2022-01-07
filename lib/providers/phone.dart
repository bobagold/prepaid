import 'package:hooks_riverpod/hooks_riverpod.dart';

final phonesProvider =
    StateNotifierProvider<PhonesNotifier, List<Phone>>((ref) {
  return PhonesNotifier();
});

class PhonesNotifier extends StateNotifier<List<Phone>> {
  PhonesNotifier() : super([]);
  void add(Phone phone) => state = [...state, phone];
}

class Phone {
  final String phone;
  const Phone(this.phone);
}
