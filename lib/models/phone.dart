import 'package:freezed_annotation/freezed_annotation.dart';

part 'phone.freezed.dart';
part 'phone.g.dart';

@freezed
class Phones with _$Phones {
  const factory Phones(List<Phone> phones) = _Phones;
  factory Phones.fromJson(Map<String, dynamic> json) => _$PhonesFromJson(json);
}

@freezed
class Limit with _$Limit {
  const factory Limit({
    required double consumed,
    required String unit,
    required String type,
    required DateTime expiration,
    required double max,
  }) = _Limit;
  factory Limit.fromJson(Map<String, dynamic> json) => _$LimitFromJson(json);
}

@freezed
class PlanOption with _$PlanOption {
  const factory PlanOption({
    String? additionalInfo,
    required bool automaticExtension,
    required String buttonText,
    String? details,
    required String formattedPrice,
    required String name,
    required String tariffoptionId,
    required Money price,
    required Duration duration,
    /* {"amount": 14,"unit": "DAY"} */
    List<String>? notBookableWith,
    bool? requiresContractSummary,
    String? statusKey,
    DateTime? startOfRuntime,
    DateTime? endOfRuntime,
    String? possibleChangingDate,
    bool? cancelable,
    bool? restrictedService,
    String? tariffState,
  }) = _PlanOption;
  factory PlanOption.fromJson(Map<String, dynamic> json) =>
      _$PlanOptionFromJson(json);
}

@freezed
class PlanOptions with _$PlanOptions {
  const factory PlanOptions(
    List<PlanOption> planOptions, {
    List<PlanOption>? booked,
  }) = _PlanOptions;
  factory PlanOptions.fromJson(Map<String, dynamic> json) =>
      _$PlanOptionsFromJson(json);
}

@freezed
class PhoneState with _$PhoneState {
  const factory PhoneState.authExpired() = AuthExpired;
  const factory PhoneState.authorized() = Authorized;
  const factory PhoneState.updated() = Updated;
}

@freezed
class Phone with _$Phone {
  const Phone._();
  const factory Phone(
    String phone, {
    String? carrier,
    Auth? auth,
    Money? balance,
    String? plan,
    Limits? limits,
    PlanOptions? planOptions,
  }) = _Phone;
  factory Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);

  @override
  String toString() {
    return '$carrier $phone';
  }

  bool sameNumber(Phone phone) => this.phone == phone.phone;
  bool notSameNumber(Phone phone) => !sameNumber(phone);

  PhoneState state() {
    if (auth?.expired() != false) {
      return const PhoneState.authExpired();
    }
    if (balance == null) {
      return const PhoneState.authorized();
    }
    return const PhoneState.updated();
  }
}

@freezed
class Auth with _$Auth {
  const Auth._();
  const factory Auth(
    String authKey,
    DateTime expiration,
  ) = _Auth;
  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);

  bool expired() => DateTime.now().isAfter(expiration);
  bool almostExpired() =>
      DateTime.now().isAfter(expiration.subtract(const Duration(minutes: 15)));
}

@freezed
class Money with _$Money {
  const factory Money(int cents) = _Money;
  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);
}

extension MoneyHuman on Money {
  String humanReadable() {
    return '€${cents / 100}';
  }

  bool lessThan(Money balance) => cents < balance.cents;
}

@freezed
class Limits with _$Limits {
  const factory Limits(
    List<Limit> limits,
  ) = _Limits;
  factory Limits.fromJson(Map<String, dynamic> json) => _$LimitsFromJson(json);
}

@freezed
class Credentials with _$Credentials {
  const factory Credentials(
    String login,
    String password,
  ) = _Credentials;
  factory Credentials.fromJson(Map<String, dynamic> json) =>
      _$CredentialsFromJson(json);
}
