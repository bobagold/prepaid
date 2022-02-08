import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/models/phone.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Lidl ${phone.phone}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${phone.plan} ${phone.balance?.humanReadable()}'),
            ...phone.limits?.limits.map(
                  (limit) => ListTile(
                    title: Text(
                        '${limit.consumed} of ${limit.max} ${limit.unit} ${limit.type}'),
                  ),
                ) ??
                [],
            TextButton(
              child: const Text('Top up'),
              onPressed: () {
                showDialog(
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
