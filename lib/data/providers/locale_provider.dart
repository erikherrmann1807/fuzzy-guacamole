import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider((_) => SettingsRepository());

/// Lädt die persistierte Sprache beim Start und erlaubt das Umschalten
/// zur Laufzeit.
class LocaleController extends StateNotifier<AsyncValue<Locale>> {
  final SettingsRepository repository;

  LocaleController(this.repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = await AsyncValue.guard(() async => Locale(await repository.loadLocaleCode()));
  }

  Future<void> setLocale(String code) async {
    await repository.saveLocaleCode(code);
    state = AsyncValue.data(Locale(code));
  }
}

final localeProvider = StateNotifierProvider<LocaleController, AsyncValue<Locale>>(
  (ref) => LocaleController(ref.watch(settingsRepositoryProvider)),
);
