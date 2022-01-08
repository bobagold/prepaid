import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:prepaid/forms/phone_add.dart';
import 'package:prepaid/models/phone.dart';

class PhoneLoginForm extends HookWidget {
  final ValueSetter<BuildContext>? onSubmit;
  final Phone phone;

  const PhoneLoginForm({Key? key, this.onSubmit, required this.phone})
      : super(key: key);

  static Future<void> showAsDialog(
    BuildContext context, {
    Future<bool> Function(BuildContext)? onSubmit,
    required Phone phone,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login for $phone'),
        content: PhoneLoginForm(
          phone: phone,
          onSubmit: (context) async {
            if (onSubmit != null) {
              var success = await onSubmit(context);
              if (!success) {
                return;
              }
            }
            Navigator.pop(context);
          },
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

  @override
  Widget build(BuildContext context) {
    final loginController = useTextEditingController(text: '');
    final passwordController = useTextEditingController(text: '');
    return Form(
      child: Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: loginController,
              key: const Key('username'),
              decoration: const InputDecoration(
                label: Text('Login'),
              ),
              validator: (value) => value?.isNotEmpty != true ? 'Empty' : null,
              onFieldSubmitted: (value) => submit(context),
              onSaved: (value) => Form.of(context)!.saved['username'] = value!,
            ),
            TextFormField(
              autofocus: true,
              controller: passwordController,
              key: const Key('password'),
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
              validator: (value) => value?.isNotEmpty != true ? 'Empty' : null,
              onFieldSubmitted: (value) => submit(context),
              onSaved: (value) => Form.of(context)!.saved['password'] = value!,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => submit(context),
              key: const Key('login'),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
