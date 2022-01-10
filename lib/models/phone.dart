class Phone {
  final String phone;
  final Auth? auth;
  final Money? balance;
  final String? plan;
  final Limits? limits;
  const Phone(this.phone, {this.auth, this.balance, this.plan, this.limits});
  @override
  String toString() {
    return 'Phone: $phone';
  }

  bool sameNumber(Phone phone) => this.phone == phone.phone;
}

class Auth {
  final String authKey;
  final DateTime expiration;

  Auth(this.authKey, this.expiration);

  bool get expired => DateTime.now().isAfter(expiration);
}

class Money {
  final int cents;

  Money(this.cents);
}

class Limits {
  final int bytesSpent;
  final int bytesLeft;
  final int minutesSpent;
  final int minutesLeft;
  final int smsSpent;
  final int smsLeft;

  Limits(
    this.bytesSpent,
    this.bytesLeft,
    this.minutesSpent,
    this.minutesLeft,
    this.smsSpent,
    this.smsLeft,
  );
}

class Credentials {
  final String login;
  final String password;

  Credentials(this.login, this.password);
}
