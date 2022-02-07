import 'package:freezed_annotation/freezed_annotation.dart';

part 'phone.freezed.dart';
part 'phone.g.dart';

@freezed
class Phones with _$Phones {
  const factory Phones(List<Phone> phones) = _Phones;
  factory Phones.fromJson(Map<String, dynamic> json) => _$PhonesFromJson(json);
}

@freezed
class Phone with _$Phone {
  const Phone._();
  const factory Phone(
    String phone, {
    Auth? auth,
    Money? balance,
    String? plan,
    Limits? limits,
  }) = _Phone;
  factory Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);

  @override
  String toString() {
    return 'Phone: $phone';
  }

  bool sameNumber(Phone phone) => this.phone == phone.phone;
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
}

@freezed
class Money with _$Money {
  const factory Money(int cents) = _Money;
  factory Money.fromJson(Map<String, dynamic> json) => _$MoneyFromJson(json);
}

@freezed
class Limits with _$Limits {
  const factory Limits(
    int bytesSpent,
    int bytesLeft,
    int minutesSpent,
    int minutesLeft,
    int smsSpent,
    int smsLeft,
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
