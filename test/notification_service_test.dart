import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/services/notification_service.dart';
import 'package:fuzzy_guacamole/l10n/app_localizations.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class MockNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

Meeting testMeeting({String? id, required DateTime start, int? reminderMinutes}) {
  return Meeting(
    meetingId: id,
    eventName: 'Standup',
    description: '',
    start: start,
    end: start.add(const Duration(hours: 1)),
    labelColor: MyColors.highLabel,
    priority: 'High',
    isAllDay: false,
    reminderMinutes: reminderMinutes,
  );
}

void main() {
  late MockNotificationsPlugin plugin;
  late NotificationService service;

  setUpAll(() {
    tz_data.initializeTimeZones();
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(tz.TZDateTime(tz.UTC, 2026));
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
  });

  setUp(() {
    plugin = MockNotificationsPlugin();
    when(() => plugin.initialize(settings: any(named: 'settings'))).thenAnswer((_) async => true);
    when(() => plugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    when(() => plugin.cancelAll()).thenAnswer((_) async {});
    when(
      () => plugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ),
    ).thenAnswer((_) async {});

    service = NotificationService(
      plugin: plugin,
      configureTimezone: () async => tz.setLocalLocation(tz.getLocation('Europe/Berlin')),
      l10nResolver: () async => lookupAppLocalizations(const Locale('de')),
    );
  });

  group('Stabile Notification-IDs', () {
    test('Gleiche Dokument-ID ergibt immer dieselbe Notification-ID', () {
      expect(NotificationService.notificationIdForMeeting('abc'), NotificationService.notificationIdForMeeting('abc'));
      expect(NotificationService.notificationIdForTask('abc'), NotificationService.notificationIdForTask('abc'));
    });

    test('Meetings und Tasks haben getrennte Namensräume', () {
      expect(
        NotificationService.notificationIdForMeeting('abc'),
        isNot(NotificationService.notificationIdForTask('abc')),
      );
    });

    test('IDs sind positive 31-Bit-Werte', () {
      for (final docId in ['a', 'xyz', 'meeting-123', '🙂']) {
        final id = NotificationService.notificationIdForMeeting(docId);
        expect(id, greaterThanOrEqualTo(0));
        expect(id, lessThanOrEqualTo(0x7FFFFFFF));
      }
    });
  });

  group('init', () {
    test('Mehrfaches init initialisiert das Plugin nur einmal', () async {
      await service.init();
      await service.init();
      verify(() => plugin.initialize(settings: any(named: 'settings'))).called(1);
    });
  });

  group('syncMeetingReminder', () {
    test('plant eine Erinnerung vor dem Termin (lokalisierter Text)', () async {
      final start = DateTime.now().add(const Duration(hours: 2));
      final meeting = testMeeting(id: 'm1', start: start, reminderMinutes: 30);

      await service.syncMeetingReminder(meeting);

      final captured = verify(
        () => plugin.zonedSchedule(
          id: NotificationService.notificationIdForMeeting('m1'),
          title: 'Standup',
          body: captureAny(named: 'body'),
          scheduledDate: captureAny(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        ),
      ).captured;

      final body = captured.whereType<String>().single;
      expect(body, startsWith('Beginnt um '));
      final scheduled = captured.whereType<tz.TZDateTime>().single;
      expect(scheduled.difference(start.subtract(const Duration(minutes: 30))).inSeconds.abs(), lessThan(1));
    });

    test('bestehende Erinnerung wird vor dem Neu-Planen abgebrochen', () async {
      final meeting = testMeeting(id: 'm1', start: DateTime.now().add(const Duration(hours: 2)), reminderMinutes: 5);

      await service.syncMeetingReminder(meeting);

      verify(() => plugin.cancel(id: NotificationService.notificationIdForMeeting('m1'))).called(1);
    });

    test('ohne reminderMinutes wird nur abgebrochen, nicht geplant', () async {
      final meeting = testMeeting(id: 'm1', start: DateTime.now().add(const Duration(hours: 2)));

      await service.syncMeetingReminder(meeting);

      verify(() => plugin.cancel(id: NotificationService.notificationIdForMeeting('m1'))).called(1);
      verifyNever(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    });

    test('Erinnerungszeitpunkte in der Vergangenheit werden nicht geplant', () async {
      final meeting = testMeeting(id: 'm1', start: DateTime.now().add(const Duration(minutes: 5)), reminderMinutes: 60);

      await service.syncMeetingReminder(meeting);

      verifyNever(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    });

    test('ohne Dokument-ID passiert nichts', () async {
      final meeting = testMeeting(start: DateTime.now().add(const Duration(hours: 2)), reminderMinutes: 5);

      await service.syncMeetingReminder(meeting);

      verifyNever(() => plugin.cancel(id: any(named: 'id')));
    });

    test('fällt bei fehlender Exact-Alarm-Berechtigung auf inexakt zurück', () async {
      when(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        ),
      ).thenThrow(PlatformException(code: 'exact_alarms_not_permitted'));

      final meeting = testMeeting(id: 'm1', start: DateTime.now().add(const Duration(hours: 2)), reminderMinutes: 5);
      await service.syncMeetingReminder(meeting);

      verify(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        ),
      ).called(1);
    });
  });

  group('syncTaskReminder', () {
    test('plant Task-Erinnerung zum gewünschten Zeitpunkt', () async {
      final reminderTime = DateTime.now().add(const Duration(hours: 3));

      await service.syncTaskReminder(taskId: 't1', title: 'Einkaufen', reminderTime: reminderTime);

      verify(
        () => plugin.zonedSchedule(
          id: NotificationService.notificationIdForTask('t1'),
          title: 'Einkaufen',
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      ).called(1);
    });

    test('ohne Erinnerungszeit wird nur abgebrochen', () async {
      await service.syncTaskReminder(taskId: 't1', title: 'Einkaufen', reminderTime: null);

      verify(() => plugin.cancel(id: NotificationService.notificationIdForTask('t1'))).called(1);
      verifyNever(
        () => plugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    });
  });

  test('cancelMeetingReminder ruft das Plugin mit der stabilen ID auf', () async {
    await service.cancelMeetingReminder('m42');
    verify(() => plugin.cancel(id: NotificationService.notificationIdForMeeting('m42'))).called(1);
  });
}
