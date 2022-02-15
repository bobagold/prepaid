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
      yield* fetchBalance(updatedPhone);
    } catch (err) {
      developer.log('error', error: err);
    }
  }

  @override
  Stream<Phone> fetchBalance(Phone phone) async* {
    var auth = phone.auth;
    if (auth == null || auth.expired()) {
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
  Stream<Phone> refresh(Phone phone) {
    return fetchBalance(phone);
  }

  @override
  Stream<Phone> fetchDetails(Phone phone) async* {
    var auth = phone.auth;
    if (auth == null || auth.expired()) {
      return;
    }
    var token = auth.toApi();
    if (auth.almostExpired()) {
      token = await LidlRepository().refresh(token);
      phone = phone.copyWith(auth: authFromApi(token));
      yield phone;
    }
    final info = await LidlRepository().fetchDetails(token);
    developer.log('info: $info');
    PlanOption restoreOption(dynamic data) => PlanOption(
          automaticExtension: data['automaticExtension'],
          buttonText: data['buttonText'],
          formattedPrice: data['formattedPrice'],
          name: data['name'],
          tariffoptionId: data['tariffoptionId'],
          price: Money(data['price']),
          duration: Duration(days: data['duration']['amount']),
          additionalInfo: data['additionalInfo'],
          details: data['details'],
          notBookableWith: (data['notBookableWith'] as List?)?.cast<String>(),
          requiresContractSummary: data['requiresContractSummary'],
          statusKey: data['statusKey'],
          startOfRuntime: data['startOfRuntime'] != null
              ? DateTime.tryParse(data['startOfRuntime'])
              : null,
          endOfRuntime: data['endOfRuntime'] != null
              ? DateTime.tryParse(data['endOfRuntime'])
              : null,
          possibleChangingDate: data['possibleChangingDate'],
          cancelable: data['cancelable'],
          restrictedService: data['restrictedService'],
          tariffState: data['tariffState'],
        );
    yield phone.copyWith(
      planOptions: PlanOptions(
        info?['bookableTariffoptions']?['bookableTariffoptions']
            ?.map(restoreOption)
            ?.toList()
            .cast<PlanOption>(),
        booked: info?['bookedTariffoptions']?['bookedTariffoptions']
            ?.map(restoreOption)
            ?.toList()
            .cast<PlanOption>(),
      ),
    );
  }

  @override
  Stream<Phone> book(Phone phone, PlanOption option) {
    throw UnimplementedError('todo');
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
