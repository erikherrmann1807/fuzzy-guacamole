import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/data/providers/locale_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/settings_repository.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/settings_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsRepository', () {
    test('liefert Defaults, wenn nichts gespeichert ist', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SettingsRepository();

      expect(await repo.loadLocaleCode(), SettingsRepository.defaultLocaleCode);
      expect(await repo.loadThemeMode(), 'system');
      expect(await repo.loadFirstWeekday(), DateTime.monday);
    });

    test('persistiert alle Einstellungen', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SettingsRepository();

      await repo.saveLocaleCode('en');
      await repo.saveThemeMode('dark');
      await repo.saveFirstWeekday(DateTime.sunday);

      expect(await repo.loadLocaleCode(), 'en');
      expect(await repo.loadThemeMode(), 'dark');
      expect(await repo.loadFirstWeekday(), DateTime.sunday);
    });

    test('ungültiger Wochenbeginn fällt auf Montag zurück', () async {
      SharedPreferences.setMockInitialValues({SettingsRepository.firstWeekdayKey: 42});
      final repo = SettingsRepository();

      expect(await repo.loadFirstWeekday(), DateTime.monday);
    });
  });

  group('SettingsViewModel', () {
    test('lädt persistierte Werte beim Start', () async {
      SharedPreferences.setMockInitialValues({
        SettingsRepository.themeModeKey: 'dark',
        SettingsRepository.firstWeekdayKey: DateTime.sunday,
      });
      final vm = SettingsViewModel(SettingsRepository());
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.themeMode, ThemeMode.dark);
      expect(vm.state.firstWeekday, DateTime.sunday);
      vm.dispose();
    });

    test('unbekannter Theme-String fällt auf System zurück', () async {
      SharedPreferences.setMockInitialValues({SettingsRepository.themeModeKey: 'quatsch'});
      final vm = SettingsViewModel(SettingsRepository());
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.themeMode, ThemeMode.system);
      vm.dispose();
    });

    test('setThemeMode und setFirstWeekday persistieren sofort', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SettingsRepository();
      final vm = SettingsViewModel(repo);
      await Future<void>.delayed(Duration.zero);

      await vm.setThemeMode(ThemeMode.light);
      await vm.setFirstWeekday(DateTime.saturday);

      expect(vm.state.themeMode, ThemeMode.light);
      expect(vm.state.firstWeekday, DateTime.saturday);
      expect(await repo.loadThemeMode(), 'light');
      expect(await repo.loadFirstWeekday(), DateTime.saturday);
      vm.dispose();
    });
  });

  group('LocaleController', () {
    test('lädt die gespeicherte Sprache und schaltet zur Laufzeit um', () async {
      SharedPreferences.setMockInitialValues({SettingsRepository.localeKey: 'en'});
      final repo = SettingsRepository();
      final controller = LocaleController(repo);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.value, const Locale('en'));

      await controller.setLocale('de');
      expect(controller.state.value, const Locale('de'));
      expect(await repo.loadLocaleCode(), 'de');
      controller.dispose();
    });
  });
}
