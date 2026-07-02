import 'package:flutter/widgets.dart';
import 'package:fuzzy_guacamole/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Kurzzugriff auf die Lokalisierung: `context.l10n.login`.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Übersetzt die persistierten Prioritätswerte ('High'/'Low') in den
/// anzuzeigenden, lokalisierten Namen. Unbekannte Werte werden unverändert
/// angezeigt.
String localizedPriorityName(BuildContext context, String priority) {
  switch (priority) {
    case 'High':
      return context.l10n.priorityHigh;
    case 'Low':
      return context.l10n.priorityLow;
    default:
      return priority;
  }
}
