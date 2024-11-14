import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:logging/logging.dart';
import 'package:prepaid/forms/phone_add.dart';
import 'package:prepaid/models/phone.dart';

final Logger _logger = Logger('PhoneLoginForm');

class PhoneLoginForm extends HookWidget {
  final Future<bool> Function(BuildContext)? onSubmit;
  final Phone phone;

  const PhoneLoginForm({Key? key, this.onSubmit, required this.phone}) : super(key: key);

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
            final navigator = Navigator.of(context);
            var success = await onSubmit?.call(context);
            if (success == false) {
              return Future.value(success);
            }
            navigator.pop();
            return Future.value(success);
          },
        ),
      ),
    );
  }

  void submit(
    BuildContext context,
    ValueNotifier<AsyncSnapshot<bool>> progress,
  ) async {
    var formState = Form.of(context);
    _logger.info('validating $formState');
    var valid = formState.validate();
    _logger.info('validated $formState $valid');
    if (valid) {
      formState.save();
    }
    if (valid && onSubmit != null) {
      _logger.info('submitting $onSubmit');
      progress.value = const AsyncSnapshot.waiting();
      var success = await onSubmit!(context);
      progress.value = AsyncSnapshot.withData(ConnectionState.done, success);
      // formState.validate()
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginController = useTextEditingController(text: '');
    final passwordController = useTextEditingController(text: '');
    final progress = useState(const AsyncSnapshot<bool>.nothing());
    final loading = progress.value.connectionState == ConnectionState.waiting;
    return AutofillForm(
      child: Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: loginController,
              autofillHints: const [AutofillHints.username],
              key: const Key('username'),
              decoration: const InputDecoration(
                label: Text('Login'),
              ),
              readOnly: loading,
              // todo add async checks with generations
              validator: (value) => value?.isNotEmpty != true ? 'Empty' : null,
              onFieldSubmitted: (value) => submit(context, progress),
              onSaved: (value) => Form.of(context).saved['username'] = value!,
            ),
            TextFormField(
              autofocus: true,
              controller: passwordController,
              autofillHints: const [AutofillHints.password],
              obscureText: true,
              key: const Key('password'),
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
              readOnly: loading,
              validator: (value) => value?.isNotEmpty != true ? 'Empty' : null,
              onFieldSubmitted: (value) => submit(context, progress),
              onSaved: (value) => Form.of(context).saved['password'] = value!,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: loading ? null : () => submit(context, progress),
              key: const Key('login'),
              child: Text(loading ? 'Loading...' : 'Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class AutofillForm extends StatelessWidget {
  const AutofillForm({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Form(child: AutofillGroup(child: child));
  }
}
