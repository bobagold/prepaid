import 'dart:developer' as developer;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';
import 'package:prepaid/providers/phones.dart';
import 'package:prepaid/src/lidl/lidl_repository.dart';

// todo move to plugin
final lidlProvider = StateNotifierProvider<LidlNotifier, void>((ref) {
  return LidlNotifier(ref.read);
});

class LidlNotifier extends StateNotifier<void> {
  LidlNotifier(this.read) : super([]);

  final Reader read;

  Future<bool> authorize(Phone phone, Credentials credentials) async {
    try {
      final token = await LidlRepository().authorize({
        'username': credentials.login,
        'password': credentials.password,
      });
      final phones = read(phonesProvider.notifier);
      var updatedPhone = Phone(
        phone.phone,
        auth: authFromApi(token),
      );
      phones.update(updatedPhone);
      fetchBalance(updatedPhone);
      return true;
    } catch (err) {
      developer.log('error', error: err);
      return false;
    }
  }

  void fetchBalance(Phone phone) async {
    var auth = phone.auth;
    if (auth == null) {
      return;
    }
    var token = auth.toApi();
    if (auth.almostExpired()) {
      token = await LidlRepository().refresh(token);
      phone = phone.copyWith(auth: authFromApi(token));
      final phones = read(phonesProvider.notifier);
      phones.update(phone);
    }
    final info = await LidlRepository().fetchBalance(token);
    developer.log('info: $info');
    final phones = read(phonesProvider.notifier);
    phones.update(phone.copyWith(
      balance: Money(info?['balance']),
      plan: info?['tariff']?['name'],
      limits: Limits(info?['consumptions']
          ?.map((consumption) => Limit(
                consumed: consumption['consumed'].toDouble(),
                max: consumption['max'].toDouble(),
                unit: consumption['unit'],
                type: consumption['type'],
                expiration: DateTime.parse(consumption['expirationDate']),
              ))
          ?.toList()
          .cast<Limit>()),
    ));
  }

  void refresh(List<Phone> phones) async {
    for (Phone phone in phones) {
      var auth = phone.auth;
      if (auth != null && !auth.expired() && auth.almostExpired()) {
        final token = await LidlRepository().refresh(auth.toApi());
        phone = phone.copyWith(auth: authFromApi(token));
        final phones = read(phonesProvider.notifier);
        phones.update(phone);
      }
    }
  }
}

extension AuthToApi on Auth {
  Map toApi() => {
        'access_token': authKey,
        'token_type': 'Bearer',
      };
}

Auth? authFromApi(Map? token) => token == null
    ? null
    : Auth(
        token['access_token'],
        DateTime.now().add(Duration(seconds: token['expires_in'] ?? 0)),
      );
