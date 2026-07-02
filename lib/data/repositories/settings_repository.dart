import 'package:shared_preferences/shared_preferences.dart';

/// Persistiert Nutzereinstellungen über SharedPreferences.
///
/// Bewusst UI-frei: der Theme-Modus wird als String ('system'/'light'/'dark')
/// gespeichert, das Mapping auf [ThemeMode] übernimmt das Settings-ViewModel.
class SettingsRepository {
  static const String localeKey = 'locale';
  static const String defaultLocaleCode = 'de';

  static const String themeModeKey = 'themeMode';
  static const String defaultThemeMode = 'system';

  static const String firstWeekdayKey = 'firstWeekday';

  /// [DateTime.monday] als Standard-Wochenbeginn.
  static const int defaultFirstWeekday = DateTime.monday;

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

  Future<String> loadThemeMode() async {
    final prefs = await _prefsProvider();
    return prefs.getString(themeModeKey) ?? defaultThemeMode;
  }

  Future<void> saveThemeMode(String mode) async {
    final prefs = await _prefsProvider();
    await prefs.setString(themeModeKey, mode);
  }

  Future<int> loadFirstWeekday() async {
    final prefs = await _prefsProvider();
    final value = prefs.getInt(firstWeekdayKey) ?? defaultFirstWeekday;
    return (value >= DateTime.monday && value <= DateTime.sunday) ? value : defaultFirstWeekday;
  }

  Future<void> saveFirstWeekday(int weekday) async {
    final prefs = await _prefsProvider();
    await prefs.setInt(firstWeekdayKey, weekday);
  }
}
