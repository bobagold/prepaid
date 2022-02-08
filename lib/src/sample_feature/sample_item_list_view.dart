import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../forms/phone_login.dart';
import '../../providers/lidl.dart';
import '../../models/phone.dart';
import '../../providers/phones.dart';
import '../../forms/phone_add.dart';
import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends HookConsumerWidget {
  const SampleItemListView({
    Key? key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  }) : super(key: key);

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phones = ref.watch(phonesProvider);
    void add(Phone phone) => ref.read(phonesProvider.notifier).add(phone);
    void remove(Phone phone) => ref.read(phonesProvider.notifier).remove(phone);
    Phone phoneFromContext(BuildContext context) =>
        Phone(Form.of(context)!.saved['phone']!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      floatingActionButton: RotatingFAB(
        onSubmit: (context) => add(phoneFromContext(context)),
        tooltip: 'Add a phone',
        child: const Icon(Icons.add),
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: phones.length,
        itemBuilder: (BuildContext context, int index) {
          final phone = phones[index];

          return Dismissible(
            key: Key('d$phone'),
            child: PhoneListItem(phone: phone),
            onDismissed: (direction) => remove(phone),
          );
        },
      ),
    );
  }
}

class PhoneListItem extends HookConsumerWidget {
  const PhoneListItem({
    Key? key,
    required this.phone,
  }) : super(key: key);

  final Phone phone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<bool> authorize(Phone phone, Credentials credentials) =>
        ref.read(lidlProvider.notifier).authorize(phone, credentials);
    void fetchBalance(Phone phone) =>
        ref.read(lidlProvider.notifier).fetchBalance(phone);
    Credentials credentialsFromContext(BuildContext context) {
      var savedFields = Form.of(context)!.saved;
      return Credentials(savedFields['username']!, savedFields['password']!);
    }

    return ListTile(
      title: Text('Lidl ${phone.phone}'),
      leading: const CircleAvatar(
        // Display the Flutter Logo image asset.
        foregroundImage: AssetImage('assets/images/flutter_logo.png'),
      ),
      subtitle: phone.state().when(
          authorized: () => TextButton(
                child: Text('Refresh ${phone.auth?.expiration}'),
                onPressed: () => fetchBalance(phone),
              ),
          updated: () => Text(
              'ok ${phone.plan} balance: ${phone.balance?.humanReadable()}'),
          authExpired: () => TextButton(
                child: Text('Login ${phone.auth?.expiration}'),
                onPressed: () {
                  PhoneLoginForm.showAsDialog(
                    context,
                    phone: phone,
                    onSubmit: (context) => authorize(
                      phone,
                      credentialsFromContext(context),
                    ),
                  );
                },
              )),
      onTap: () {
        // Navigate to the details page. If the user leaves and returns to
        // the app after it has been killed while running in the
        // background, the navigation stack is restored.
        Navigator.restorablePushNamed(
          context,
          SampleItemDetailsView.routeName,
          arguments: phone.phone,
        );
      },
    );
  }
}

class RotatingFAB extends HookWidget {
  final Widget child;
  final ValueSetter<BuildContext>? onSubmit;
  final String? tooltip;

  const RotatingFAB({
    Key? key,
    required this.child,
    this.onSubmit,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 100),
      upperBound: 1 / 8,
    );
    return FloatingActionButton(
      onPressed: () async {
        controller.forward();
        await PhoneAddForm.showAsDialog(context, onSubmit: onSubmit);
        controller.reverse();
      },
      tooltip: tooltip,
      child: RotationTransition(turns: controller, child: child),
    );
  }
}
