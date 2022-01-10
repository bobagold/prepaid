import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';

final phonesProvider =
    StateNotifierProvider<PhonesNotifier, List<Phone>>((ref) {
  return PhonesNotifier();
});

class PhonesNotifier extends StateNotifier<List<Phone>> {
  PhonesNotifier() : super([]);
  void add(Phone phone) => state = [...state, phone];
  void update(Phone phone) =>
      state = state.map((p) => p.sameNumber(phone) ? phone : p).toList();
}
