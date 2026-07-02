import 'package:shared_preferences/shared_preferences.dart';

/// Persistiert Nutzereinstellungen über SharedPreferences.
class SettingsRepository {
  static const String localeKey = 'locale';
  static const String defaultLocaleCode = 'de';

  final Future<SharedPreferences> Function() _prefsProvider;

  SettingsRepository({Future<SharedPreferences> Function()? prefsProvider})
    : _prefsProvider = prefsProvider ?? SharedPreferences.getInstance;

  Future<String> loadLocaleCode() async {
    final prefs = await _prefsProvider();
    return prefs.getString(localeKey) ?? defaultLocaleCode;
  }

  Future<void> saveLocaleCode(String code) async {
    final prefs = await _prefsProvider();
    await prefs.setString(localeKey, code);
  }
}
