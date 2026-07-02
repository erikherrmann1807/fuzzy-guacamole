import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/locale_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/settings_repository.dart';

class SettingsState {
  final ThemeMode themeMode;

  /// Erster Wochentag der Kalenderansichten ([DateTime.monday] … [DateTime.sunday]).
  final int firstWeekday;

  const SettingsState({this.themeMode = ThemeMode.system, this.firstWeekday = SettingsRepository.defaultFirstWeekday});

  SettingsState copyWith({ThemeMode? themeMode, int? firstWeekday}) {
    return SettingsState(themeMode: themeMode ?? this.themeMode, firstWeekday: firstWeekday ?? this.firstWeekday);
  }
}

/// Lädt Dark-Mode und Wochenbeginn beim Start und persistiert Änderungen.
/// (Die Sprache läuft über den bestehenden [localeProvider].)
class SettingsViewModel extends StateNotifier<SettingsState> {
  final SettingsRepository repository;

  SettingsViewModel(this.repository) : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final themeMode = _themeModeFromString(await repository.loadThemeMode());
    final firstWeekday = await repository.loadFirstWeekday();
    if (!mounted) return;
    state = SettingsState(themeMode: themeMode, firstWeekday: firstWeekday);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await repository.saveThemeMode(mode.name);
  }

  Future<void> setFirstWeekday(int weekday) async {
    state = state.copyWith(firstWeekday: weekday);
    await repository.saveFirstWeekday(weekday);
  }

  static ThemeMode _themeModeFromString(String value) {
    return ThemeMode.values.firstWhere((m) => m.name == value, orElse: () => ThemeMode.system);
  }
}

final settingsViewModelProvider = StateNotifierProvider<SettingsViewModel, SettingsState>(
  (ref) => SettingsViewModel(ref.watch(settingsRepositoryProvider)),
);
