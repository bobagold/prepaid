import 'dart:convert';
import 'dart:developer' as developer;

import 'package:prepaid/models/phone.dart';
import 'package:prepaid/models/carrier_interface.dart';
import 'package:prepaid/src/lidl/lidl_repository.dart';

class LidlNotifier implements CarrierInterface {
  @override
  Stream<Phone> authorize(Phone phone, Credentials credentials) async* {
    try {
      final token = await LidlRepository().authorize({
        'username': credentials.login,
        'password': credentials.password,
      });
      var updatedPhone = phone.copyWith(
        auth: authFromApi(token),
      );
      yield updatedPhone;
      await for (final update in fetchBalance(updatedPhone)) {
        yield update;
      }
    } catch (err) {
      developer.log('error', error: err);
    }
  }

  @override
  Stream<Phone> fetchBalance(Phone phone) async* {
    var auth = phone.auth;
    if (auth == null) {
      return;
    }
    var token = auth.toApi();
    if (auth.almostExpired()) {
      token = await LidlRepository().refresh(token);
      phone = phone.copyWith(auth: authFromApi(token));
      yield phone;
    }
    final info = await LidlRepository().fetchBalance(token);
    developer.log('info: $info');
    yield phone.copyWith(
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
    );
  }

  @override
  Stream<Phone> refresh(Phone phone) async* {
    var auth = phone.auth;
    if (auth != null && !auth.expired() && auth.almostExpired()) {
      try {
        final oldToken = auth.toApi();
        final token = await LidlRepository().refresh(oldToken);
        phone = phone.copyWith(auth: authFromApi(token));
        yield phone;
      } catch (err) {
        developer.log('failed to refresh', error: err);
        phone = phone.copyWith(auth: null);
        yield phone;
      }
    }
  }

  @override
  String get name => 'lidl';

  @override
  String get title => 'Lidl';
}

extension AuthToApi on Auth {
  Map toApi() => jsonDecode(authKey);
}

Auth? authFromApi(Map? token) => token == null
    ? null
    : Auth(
        jsonEncode(token),
        DateTime.now().add(Duration(seconds: token['expires_in'] ?? 0)),
      );
