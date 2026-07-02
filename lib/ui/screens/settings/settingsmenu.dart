import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/locale_provider.dart';
import 'package:fuzzy_guacamole/l10n/l10n_extensions.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/settings_viewmodel.dart';
import 'package:intl/intl.dart';

/// Einstellungen: Sprache, Dark Mode und erster Wochentag.
/// Alle Werte werden über das Settings-/Locale-ViewModel persistiert.
class SettingsMenu extends ConsumerWidget {
  const SettingsMenu({super.key});

  /// Angebotene Wochenstarts (Montag, Samstag, Sonntag).
  static const List<int> _firstWeekdayOptions = [DateTime.monday, DateTime.saturday, DateTime.sunday];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsViewModelProvider);
    final settingsVm = ref.read(settingsViewModelProvider.notifier);
    final localeAsync = ref.watch(localeProvider);
    final localeController = ref.read(localeProvider.notifier);
    final locale = Localizations.maybeLocaleOf(context)?.toString();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          trailing: DropdownButton<String>(
            value: localeAsync.value?.languageCode,
            items: [
              DropdownMenuItem(value: 'de', child: Text(l10n.languageGerman)),
              DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
            ],
            onChanged: (code) {
              if (code != null) localeController.setLocale(code);
            },
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.brightness_6_outlined),
          title: Text(l10n.theme),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) => settingsVm.setThemeMode(selection.first),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.calendar_view_week_outlined),
          title: Text(l10n.firstDayOfWeek),
          trailing: DropdownButton<int>(
            value: settings.firstWeekday,
            items: _firstWeekdayOptions
                .map((weekday) => DropdownMenuItem(value: weekday, child: Text(_weekdayName(weekday, locale))))
                .toList(),
            onChanged: (weekday) {
              if (weekday != null) settingsVm.setFirstWeekday(weekday);
            },
          ),
        ),
      ],
    );
  }

  /// Lokalisierter Wochentagsname über intl (5.1.2026 ist ein Montag).
  static String _weekdayName(int weekday, String? locale) {
    final monday = DateTime(2026, 1, 5);
    return DateFormat.EEEE(locale).format(monday.add(Duration(days: weekday - DateTime.monday)));
  }
}
