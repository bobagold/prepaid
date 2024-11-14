import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:prepaid/providers/settings.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  Logger.root.onRecord.listen((event) {
    if (kDebugMode) {
      print('${event.level} ${event.loggerName} ${event.message} ${event.error}');
    }
  });
  Dio().interceptors.add(
        LogInterceptor(
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(ProviderScope(
    overrides: [settingsProvider.overrideWith((_) => settingsController)],
    child: const MyApp(),
  ));
}
