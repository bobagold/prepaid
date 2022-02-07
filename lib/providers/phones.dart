import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';
import 'package:prepaid/providers/storage.dart';

final phonesProvider = StateNotifierProvider<PhonesNotifier, List<Phone>>(
    (ref) => PhonesNotifier(ref));

class PhonesNotifier extends StateNotifier<List<Phone>> {
  PhonesNotifier(this.ref) : super([]) {
    _init();
  }

  final Ref ref;

  void add(Phone phone) => _save(state = [...state, phone]);
  void update(Phone phone) =>
      _save(state = state.map((p) => p.sameNumber(phone) ? phone : p).toList());

  void _init() async {
    await ref.read(storageProvider).read('test');
  }

  void _save(List<Phone> phone) {
    ref.read(storageProvider).write('test', 'saved');
  }
}
