import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prepaid/src/settings/settings_controller.dart';

final settingsProvider = ChangeNotifierProvider<SettingsController>((ref) {
  // please override in root ProviderScope to prevent blinks
  // final settingsController = SettingsController(SettingsService());
  // settingsController.loadSettings();
  // return settingsController;
  throw Exception('will blink');
});
