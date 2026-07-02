import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/l10n/app_localizations.dart';
import 'package:fuzzy_guacamole/utils/utils.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Kapselt das komplette Scheduling lokaler Benachrichtigungen
/// (Termin- und Task-Erinnerungen) inklusive Zeitzonen-Handling.
///
/// Läuft vollständig lokal auf dem Gerät – kein FCM, kein Server.
class NotificationService {
  static const String _channelId = 'reminders';
  static const String _channelName = 'Reminders';
  static const String _channelDescription = 'Termin- und Task-Erinnerungen';

  final FlutterLocalNotificationsPlugin _plugin;

  /// Konfiguriert die lokale Zeitzone; im Test austauschbar.
  final Future<void> Function() _configureTimezone;

  /// Liefert die Lokalisierung für Benachrichtigungstexte (context-frei).
  final Future<AppLocalizations> Function() _l10nResolver;

  bool _initialized = false;

  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    Future<void> Function()? configureTimezone,
    required Future<AppLocalizations> Function() l10nResolver,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _configureTimezone = configureTimezone ?? _configureDeviceTimezone,
       _l10nResolver = l10nResolver;

  static Future<void> _configureDeviceTimezone() async {
    tz_data.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
  }

  /// Initialisiert Plugin und Zeitzone. Mehrfachaufrufe sind unschädlich.
  Future<void> init() async {
    if (_initialized) return;
    await _configureTimezone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(
          // Berechtigungen werden separat über requestPermissions() angefragt.
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  /// Fragt die Notification-Berechtigung an (Android 13+ / iOS).
  /// Liefert `true`, wenn Benachrichtigungen erlaubt sind.
  Future<bool> requestPermissions() async {
    await init();
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true;
  }

  // --- Termin-Erinnerungen ---

  /// Plant bzw. aktualisiert die Erinnerung eines Termins.
  /// Ohne [Meeting.reminderMinutes] oder bei Zeitpunkten in der Vergangenheit
  /// wird eine bestehende Erinnerung nur abgebrochen.
  Future<void> syncMeetingReminder(Meeting meeting) async {
    final id = meeting.meetingId;
    if (id == null) return;

    await cancelMeetingReminder(id);

    final reminderTime = meeting.reminderTime;
    if (reminderTime == null || !reminderTime.isAfter(DateTime.now())) return;

    final l10n = await _l10nResolver();
    await _schedule(
      notificationId: notificationIdForMeeting(id),
      title: meeting.eventName,
      body: l10n.meetingReminderBody(CalendarUtils.formatHHmm(meeting.start)),
      scheduledTime: reminderTime,
    );
  }

  Future<void> cancelMeetingReminder(String meetingId) async {
    await init();
    await _plugin.cancel(id: notificationIdForMeeting(meetingId));
  }

  // --- Task-Erinnerungen ---

  /// Plant bzw. aktualisiert die Erinnerung eines Daily Tasks.
  Future<void> syncTaskReminder({required String taskId, required String title, required DateTime? reminderTime}) async {
    await cancelTaskReminder(taskId);
    if (reminderTime == null || !reminderTime.isAfter(DateTime.now())) return;

    final l10n = await _l10nResolver();
    await _schedule(
      notificationId: notificationIdForTask(taskId),
      title: title,
      body: l10n.taskReminderBody,
      scheduledTime: reminderTime,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await init();
    await _plugin.cancel(id: notificationIdForTask(taskId));
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  // --- intern ---

  Future<void> _schedule({
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await init();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    try {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException {
      // Keine Berechtigung für exakte Alarme (Android 12+):
      // ungenaues Scheduling ist besser als gar keine Erinnerung.
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: tzTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Stabile (plattformunabhängige) Notification-IDs aus Dokument-IDs.
  /// Meetings und Tasks bekommen getrennte Namensräume.
  @visibleForTesting
  static int notificationIdForMeeting(String meetingId) => _stableHash('meeting:$meetingId');

  @visibleForTesting
  static int notificationIdForTask(String taskId) => _stableHash('task:$taskId');

  /// FNV-1a-Hash, begrenzt auf positive 31-Bit-Werte (Android-Notification-ID).
  static int _stableHash(String input) {
    const int fnvPrime = 0x01000193;
    int hash = 0x811C9DC5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * fnvPrime) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }
}
