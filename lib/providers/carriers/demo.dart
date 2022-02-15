import 'package:prepaid/models/phone.dart';
import 'package:prepaid/models/carrier_interface.dart';

class DemoCarrier implements CarrierInterface {
  @override
  Stream<Phone> authorize(Phone phone, Credentials credentials) async* {
    await Future.delayed(const Duration(seconds: 1));
    final updatedPhone = phone.copyWith(
      auth: Auth('xxx', DateTime.now().add(const Duration(hours: 1))),
    );
    yield updatedPhone;
    yield* fetchBalance(updatedPhone);
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
      planOptions: const PlanOptions([
        PlanOption(
          additionalInfo: "0,99 €/Tag",
          automaticExtension: false,
          buttonText: "Es werden sofort 0,99 € von deinem Guthaben abgebucht",
          details: "Speed-Bucket Smart XS (500 MB): 500 MB zusätzliches ...",
          formattedPrice: "0,99 €",
          name: "Speed-Bucket Smart XS (500 MB)",
          tariffoptionId: "CCS_92004",
          price: Money(99),
          duration: Duration(days: 14),
          notBookableWith: [],
          requiresContractSummary: false,
        ),
      ]),
    );
  }

  @override
  Stream<Phone> fetchDetails(Phone phone) => refresh(phone);

  @override
  String get name => 'demo';

  @override
  String get title => 'Demo';

  @override
  Stream<Phone> book(Phone phone, PlanOption option) async* {
    await Future.delayed(const Duration(seconds: 1));
    var planOptions = phone.copyWith.planOptions;
    if (planOptions == null) {
      return;
    }
    yield planOptions(booked: [...phone.planOptions?.booked ?? [], option]);
  }
}
