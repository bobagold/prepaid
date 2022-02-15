import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';
import 'package:prepaid/providers/carrier.dart';
import 'package:prepaid/providers/phones.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends HookConsumerWidget {
  const SampleItemDetailsView({Key? key}) : super(key: key);

  static const routeName = '/sample_item';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var phoneNumber = ModalRoute.of(context)?.settings.arguments;
    final phones = ref.watch(phonesProvider);
    final phone = phones.firstWhere((phone) => phone.phone == phoneNumber);
    Future<void> refresh() =>
        ref.read(carrierProvider.notifier).fetchDetails(phone);
    return Scaffold(
      appBar: AppBar(
        title: Text('$phone'),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          children: [
            ListTile(
              title: Text('${phone.plan} ${phone.balance?.humanReadable()}'),
            ),
            ...phone.limits?.limits.map(
                  (limit) => LimitListItem(limit: limit),
                ) ??
                [],
            ...phone.planOptions?.booked
                    ?.map((option) => BookedPlanOptionListItem(
                          phone: phone,
                          option: option,
                        )) ??
                [],
            ...phone.planOptions?.planOptions
                    .map((option) => PlanOptionListItem(
                          phone: phone,
                          option: option,
                        )) ??
                [],
            TextButton(
              child: const Text('Top up'),
              onPressed: () {
                confirm(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension DateTimeHumanDate on DateTime {
  String humanDate() => toIso8601String().split('T').first;
}

class BookedPlanOptionListItem extends StatelessWidget {
  final Phone phone;
  final PlanOption option;

  const BookedPlanOptionListItem({
    Key? key,
    required this.phone,
    required this.option,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(option.name),
      subtitle: Text(
          '${option.price.humanReadable()} / ${option.duration.inDays} days'
          ' until ${option.endOfRuntime?.humanDate()}'),
    );
  }
}

class PlanOptionListItem extends HookConsumerWidget {
  const PlanOptionListItem({
    Key? key,
    required this.phone,
    required this.option,
  }) : super(key: key);

  final Phone phone;
  final PlanOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<bool> book(phone, option) =>
        ref.read(carrierProvider.notifier).book(phone, option);
    final progress = useState(const AsyncSnapshot<bool>.nothing());
    final loading = progress.value.connectionState == ConnectionState.waiting;
    return ListTile(
      title: Text(option.name),
      subtitle: Text(
          '${option.price.humanReadable()} / ${option.duration.inDays} days'),
      trailing: TextButton(
        onPressed: loading
            ? null
            : () async {
                if (await confirm(context) == true) {
                  progress.value = const AsyncSnapshot.waiting();
                  final success = await book(phone, option);
                  progress.value =
                      AsyncSnapshot.withData(ConnectionState.done, success);
                }
              },
        child: Text(loading ? 'Loading...' : 'Book'),
      ),
    );
  }
}

class LimitListItem extends StatelessWidget {
  const LimitListItem({
    Key? key,
    required this.limit,
  }) : super(key: key);

  final Limit limit;

  @override
  Widget build(BuildContext context) {
    return LimitDecoration(
      limit: limit,
      child: ListTile(
        title: Text(
            '${limit.consumed} of ${limit.max} ${limit.unit} ${limit.type}'),
      ),
    );
  }
}

class LimitDecoration extends StatelessWidget {
  const LimitDecoration({
    Key? key,
    required this.limit,
    required this.child,
  }) : super(key: key);

  final Limit limit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delta = [0, limit.max].contains(limit.consumed) ? 0 : 0.1;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.red.withOpacity(0.2),
          Colors.green.withOpacity(0.2)
        ], stops: [
          max(0, limit.consumed / limit.max - delta),
          min(1, limit.consumed / limit.max + delta)
        ]),
      ),
      child: child,
    );
  }
}

Future<bool?> confirm(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sure?'),
      content: const Text('It costs!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('ok'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('no'),
        ),
      ],
    ),
  );
}
