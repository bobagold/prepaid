import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';
import 'package:prepaid/providers/storage.dart';

final phonesProvider = StateNotifierProvider<PhonesNotifier, List<Phone>>(
    (ref) => PhonesNotifier(ref.read));

class PhonesNotifier extends StateNotifier<List<Phone>> {
  PhonesNotifier(this.read) : super([]) {
    _init();
  }

  final Reader read;

  void add(Phone phone) => _save(state = [...state, phone]);
  void remove(Phone phone) =>
      _save(state = state.where(phone.notSameNumber).toList());
  void update(Phone phone) =>
      _save(state = state.map((p) => p.sameNumber(phone) ? phone : p).toList());

  void _init() async {
    var source = await read(storageProvider).read('phones');
    if (source != null) {
      state = Phones.fromJson(jsonDecode(source)).phones;
    }
  }

  void _save(List<Phone> phones) {
    read(storageProvider).write('phones', jsonEncode(Phones(phones).toJson()));
  }
}
