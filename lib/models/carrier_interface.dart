import 'package:prepaid/models/phone.dart';

abstract class CarrierInterface {
  String get name;
  String get title;

  Stream<Phone> authorize(Phone phone, Credentials credentials);

  Stream<Phone> fetchBalance(Phone phone);

  Stream<Phone> refresh(Phone phone);

  Stream<Phone> book(Phone phone, PlanOption option);

  Stream<Phone> fetchDetails(Phone phone);
}
