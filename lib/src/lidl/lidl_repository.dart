import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class LidlRepository {
  static const commonHeaders = {
    "accept-language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7,de;q=0.6",
    "content-type": "application/json",
    "sec-ch-ua":
        "\" Not A;Brand\";v=\"99\", \"Chromium\";v=\"96\", \"Google Chrome\";v=\"96\"",
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": "\"macOS\"",
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "same-site",
    "sec-gpc": "1",
    "Referer": "https://kundenkonto.lidl-connect.de/",
    "Referrer-Policy": "strict-origin-when-cross-origin"
  };

  Future<Map?> fetchJson(
    String url, {
    required Map<String, String> headers,
    required Map data,
  }) async {
    developer.log('data: ${jsonEncode(data)}');
    developer.log('headers: ${jsonEncode(headers)}');
    final response = await Dio().post<Map>(
      url,
      options: Options(headers: headers),
      data: data,
    );
    developer.log(
        'code: ${response.statusCode}, message: ${response.statusMessage}');
    developer.log('response: $response');
    return response.data;
  }

  Future<void> fetch(
    String url, {
    required Map<String, String> headers,
    required Map data,
    required String method,
  }) async {
    await Dio().post(
      url,
      options: Options(headers: headers, method: method),
      data: data,
    );
  }

  Future<Map?> ask(Map token, Map<String, dynamic> query) {
    return fetchJson(
      "https://api.lidl-connect.de/api/graphql",
      headers: {
        'authorization': [token['token_type'], token['access_token']].join(" "),
        'accept': "*/*",
        ...commonHeaders
      },
      data: {'operationName': null, 'variables': {}, ...query},
    );
  }

  Future<Map?> authorize(Map auth) {
    return fetchJson(
      "https://api.lidl-connect.de/api/token",
      headers: {
        "x-transaction": "Auth-c0a21e22-anonymous",
        "accept": "application/json, text/plain, */*",
        ...commonHeaders
      },
      data: {
        "grant_type": 'password',
        "client_id": 'lidl',
        "client_secret": 'lidl',
        ...auth
      },
    );
  }

  Future refresh(Map token) {
    return fetchJson(
      "https://api.lidl-connect.de/api/token",
      headers: {
        "accept": "application/json, text/plain, */*",
        "x-transaction": "Auth-c0a21e22-195432049",
        ...commonHeaders
      },
      data: {
        "grant_type": "refresh_token",
        "client_id": "lidl",
        "client_secret": "lidl",
        "refresh_token": token['refresh_token']
      },
    );
  }

  Future logout(token) {
    return fetch("https://api.lidl-connect.de/api/token",
        headers: {
          "accept": "application/json, text/plain, */*",
          "x-transaction": "Auth-c0a21e22-195432049",
          ...commonHeaders
        },
        data: {"access_token": token.access_token},
        method: "DELETE");
  }

  Future bookTariffOption(Map token, Map bookTariffoptionInput) async {
    final bookTariffoption = await ask(token, {
      "operationName": "tariffOptions",
      "variables": {"bookTariffoptionInput": bookTariffoptionInput},
      "query": '''
mutation tariffOptions(\$bookTariffoptionInput: BookTariffoptionInput!) {
  bookTariffoption(bookTariffoption: \$bookTariffoptionInput) {
    success
    processId
    bookTariffoptionDocumentUrl
    __typename
  }
}
'''
          .trim()
    });
    developer.log('booked: $bookTariffoption');
    developer.log(bookTariffoption?['data']?.bookTariffoption?.processId);
    final confirmTariffoptionBookingInput = await ask(token, {
      "operationName": "tariffOptions",
      "variables": {
        "confirmTariffoptionBookingInput": {
          "processId": bookTariffoption?['data']?.bookTariffoption?.processId
        }
      },
      "query": '''
mutation tariffOptions(\$confirmTariffoptionBookingInput: ConfirmTariffoptionBookingInput!) {
  confirmTariffoptionBooking(
    confirmTariffoptionBooking: \$confirmTariffoptionBookingInput
  ) {
    success
    __typename
  }
}
'''
          .trim()
    });
    developer.log('confirmed: $confirmTariffoptionBookingInput');
  }

  Future<Map?> fetchBalance(Map token) async {
    final tariff = await fetchTariff(token);
    final consumptions = await fetchConsumptions(token);
    final balance = await _fetchBalance(token);
    return {
      'tariff': tariff,
      'consumptions': consumptions,
      'balance': balance,
    };
  }

  Future<int?> _fetchBalance(Map token) async {
    final currentCustomer = await ask(token, {
      'query': '''
query balanceInfo {
  currentCustomer {
    balance
    contract {
      msisdn
      __typename
    }
    __typename
  }
}'''
          .trim()
    });
    return currentCustomer?['data']?['currentCustomer']?['balance'];
  }

  Future<Map?> fetchTariff(Map token) async {
    final tariff = await ask(token, {
      'query': '''
{
  tariffs {
    bookedTariff {
      tariffId
      name
      runtime {
        amount
        unit
        __typename
      }
      phoneFlat
      basicFee
      smsFlat
      __typename
    }
    __typename
  }
}'''
          .trim()
    });
    final bookedTariff = tariff?['data']?['tariffs']?['bookedTariff'];
    return bookedTariff;
  }

  Future<List?> fetchConsumptions(Map token) async {
    final consumptions = await ask(token, {
      'query': '''
query consumptions {
  consumptions {
    consumptionsForUnit {
      consumed
      unit
      formattedUnit
      type
      description
      expirationDate
      left
      max
      __typename
    }
    __typename
  }
}'''
          .trim()
    });
    return consumptions?['data']?['consumptions']?['consumptionsForUnit'];
  }
}
