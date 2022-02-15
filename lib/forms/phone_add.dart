import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/providers/carrier.dart';

class PhoneAddForm extends HookConsumerWidget {
  final ValueSetter<BuildContext>? onSubmit;

  const PhoneAddForm({
    Key? key,
    this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useTextEditingController(text: '');
    final carriers = ref.watch(carrierProvider);
    return Form(
      child: Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: carriers.first.name,
              key: const Key('phone_carrier'),
              items: carriers
                  .map(
                    (carrier) => DropdownMenuItem(
                      child: Text(carrier.title),
                      value: carrier.name,
                    ),
                  )
                  .toList(),
              onChanged: (value) {},
              onSaved: (value) => Form.of(context)!.saved['carrier'] = value!,
            ),
            TextFormField(
              autofocus: true,
              controller: controller,
              autofillHints: const [AutofillHints.telephoneNumberNational],
              key: const Key('phone_number'),
              validator: (value) => value?.isNotEmpty != true ? 'Empty' : null,
              onFieldSubmitted: (value) => submit(context),
              onSaved: (value) => Form.of(context)!.saved['phone'] = value!,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => submit(context),
              key: const Key('phone_submit'),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void submit(BuildContext context) {
    var formState = Form.of(context);
    var valid = formState!.validate();
    if (valid) {
      formState.save();
    }
    if (valid && onSubmit != null) {
      onSubmit!(context);
    }
  }

  static Future<void> showAsDialog(
    BuildContext context, {
    ValueSetter<BuildContext>? onSubmit,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a phone'),
        content: PhoneAddForm(onSubmit: (context) {
          if (onSubmit != null) {
            onSubmit(context);
          }
          Navigator.pop(context);
        }),
      ),
    );
  }
}

// todo migrate to hooks
Map<FormState, Map<String, String>> _savedFields = {};

extension FormStateFields on FormState {
  Map<String, String> get saved =>
      _savedFields[this] ?? (_savedFields[this] = {});
}
