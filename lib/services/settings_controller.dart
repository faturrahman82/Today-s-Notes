import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this.preferences)
    : isDarkMode = preferences.getBool(_darkModeKey) ?? false,
      hasSeenOnboarding = preferences.getBool(_onboardingKey) ?? false;

  static const _darkModeKey = 'dark_mode';
  static const _onboardingKey = 'onboarding_seen';

  final SharedPreferences preferences;
  bool isDarkMode;
  bool hasSeenOnboarding;

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    notifyListeners();
    await preferences.setBool(_darkModeKey, value);
  }

  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    notifyListeners();
    await preferences.setBool(_onboardingKey, true);
  }
}
