import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PhoneAddForm extends HookWidget {
  final ValueSetter<BuildContext>? onSubmit;

  const PhoneAddForm({
    Key? key,
    this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: '');
    return Form(
      child: Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: controller,
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
