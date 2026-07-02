import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/locale_provider.dart';
import 'package:fuzzy_guacamole/data/services/notification_service.dart';
import 'package:fuzzy_guacamole/l10n/app_localizations.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  return NotificationService(
    // Benachrichtigungstexte in der aktuell gespeicherten App-Sprache.
    l10nResolver: () async => lookupAppLocalizations(Locale(await settingsRepository.loadLocaleCode())),
  );
});
