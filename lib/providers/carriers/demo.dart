import 'package:prepaid/models/phone.dart';
import 'package:prepaid/models/carrier_interface.dart';

class DemoCarrier implements CarrierInterface {
  @override
  Stream<Phone> authorize(Phone phone, Credentials credentials) async* {
    await Future.delayed(const Duration(seconds: 1));
    yield phone.copyWith(
      auth: Auth('xxx', DateTime.now().add(const Duration(hours: 1))),
    );
  }

  @override
  Stream<Phone> fetchBalance(Phone phone) async* {
    await Future.delayed(const Duration(seconds: 1));
    yield phone.copyWith(
      balance: const Money(50),
    );
  }

  @override
  Stream<Phone> refresh(Phone phone) async* {
    await Future.delayed(const Duration(seconds: 1));
    yield phone.copyWith(
      auth: Auth('yyy', DateTime.now().add(const Duration(hours: 1))),
    );
  }

  @override
  String get name => 'demo';

  @override
  String get title => 'Demo';
}
