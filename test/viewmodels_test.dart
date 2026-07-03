import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/providers/notification_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/database/meeting_repository.dart';
import 'package:fuzzy_guacamole/data/repositories/database/task_repository.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/data/services/local_cache_service.dart';
import 'package:fuzzy_guacamole/data/services/notification_service.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/calendar_viewmodel.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationService extends Mock implements NotificationService {}

Meeting testMeeting({String? id, String name = 'Meeting', int? reminderMinutes}) {
  return Meeting(
    meetingId: id,
    eventName: name,
    description: '',
    start: DateTime(2026, 7, 2, 10),
    end: DateTime(2026, 7, 2, 11),
    labelColor: MyColors.highLabel,
    priority: 'High',
    isAllDay: false,
    reminderMinutes: reminderMinutes,
  );
}

void main() {
  late Directory tempDir;
  late FakeFirebaseFirestore firestore;
  late MockNotificationService notifications;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(testMeeting());
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_vm_test');
    Hive.init(tempDir.path);
    firestore = FakeFirebaseFirestore();
    notifications = MockNotificationService();
    when(() => notifications.syncMeetingReminder(any())).thenAnswer((_) async {});
    when(() => notifications.cancelMeetingReminder(any())).thenAnswer((_) async {});
    when(
      () => notifications.syncTaskReminder(
        taskId: any(named: 'taskId'),
        title: any(named: 'title'),
        reminderTime: any(named: 'reminderTime'),
      ),
    ).thenAnswer((_) async {});
    when(() => notifications.cancelTaskReminder(any())).thenAnswer((_) async {});

    final db = DatabaseService(fireStore: firestore, uid: 'user_123');
    final cache = LocalCacheService(uid: 'user_123');
    container = ProviderContainer(
      overrides: [
        meetingRepositoryProvider.overrideWithValue(MeetingRepository(db, cache)),
        taskRepositoryProvider.overrideWithValue(TaskRepository(db, cache)),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  /// Wartet, bis der Snapshot-Stream den State aktualisiert hat.
  Future<void> pumpEventQueue() => Future<void>.delayed(const Duration(milliseconds: 50));

  group('MeetingsViewModel', () {
    test('add legt den Termin an und plant die Erinnerung mit der neuen ID', () async {
      final vm = container.read(meetingsViewModelProvider.notifier);

      final ok = await vm.add(testMeeting(name: 'Neu', reminderMinutes: 15));
      await pumpEventQueue();

      expect(ok, isTrue);
      final state = container.read(meetingsViewModelProvider);
      expect(state.items.map((m) => m.eventName), ['Neu']);

      final synced = verify(() => notifications.syncMeetingReminder(captureAny())).captured.single as Meeting;
      expect(synced.meetingId, state.items.single.meetingId);
      expect(synced.reminderMinutes, 15);
    });

    test('remove löscht den Termin und bricht die Erinnerung ab', () async {
      final vm = container.read(meetingsViewModelProvider.notifier);
      await vm.add(testMeeting(name: 'Neu'));
      await pumpEventQueue();
      final id = container.read(meetingsViewModelProvider).items.single.meetingId!;

      final ok = await vm.remove(id);
      await pumpEventQueue();

      expect(ok, isTrue);
      expect(container.read(meetingsViewModelProvider).items, isEmpty);
      verify(() => notifications.cancelMeetingReminder(id)).called(1);
    });

    test('Notification-Fehler lassen die Mutation nicht scheitern', () async {
      when(() => notifications.syncMeetingReminder(any())).thenThrow(Exception('kein Plugin'));
      final vm = container.read(meetingsViewModelProvider.notifier);

      final ok = await vm.add(testMeeting(name: 'Neu'));
      await pumpEventQueue();

      expect(ok, isTrue);
      expect(container.read(meetingsViewModelProvider).error, isNull);
      expect(container.read(meetingsViewModelProvider).items, hasLength(1));
    });
  });

  group('DailyTasksViewModel', () {
    final day = DateTime(2026, 7, 2);

    test('add/toggleDone/remove aktualisieren den State über den Stream', () async {
      final sub = container.listen(dailyTasksViewModelProvider, (_, _) {});
      final vm = container.read(dailyTasksViewModelProvider.notifier);

      await vm.add('Einkaufen');
      await pumpEventQueue();
      var state = container.read(dailyTasksViewModelProvider);
      expect(state.items.single.title, 'Einkaufen');
      expect(state.items.single.isDoneOn(day), isFalse);

      await vm.toggleDone(state.items.single, day);
      await pumpEventQueue();
      state = container.read(dailyTasksViewModelProvider);
      expect(state.items.single.isDoneOn(day), isTrue);
      // An einem anderen Tag gilt sie wieder als unerledigt.
      expect(state.items.single.isDoneOn(DateTime(2026, 7, 3)), isFalse);

      await vm.toggleDone(state.items.single, day);
      await pumpEventQueue();
      expect(container.read(dailyTasksViewModelProvider).items.single.isDoneOn(day), isFalse);

      await vm.remove(container.read(dailyTasksViewModelProvider).items.single);
      await pumpEventQueue();
      expect(container.read(dailyTasksViewModelProvider).items, isEmpty);

      sub.close();
    });

    test('Erinnerung wird beim Anlegen geplant und bleibt beim Abhaken bestehen', () async {
      final sub = container.listen(dailyTasksViewModelProvider, (_, _) {});
      final vm = container.read(dailyTasksViewModelProvider.notifier);

      final reminderTime = DateTime(2026, 7, 2, 9);
      await vm.add('Einkaufen', reminderTime: reminderTime);
      await pumpEventQueue();
      final task = container.read(dailyTasksViewModelProvider).items.single;

      verify(
        () => notifications.syncTaskReminder(taskId: task.taskId!, title: 'Einkaufen', reminderTime: reminderTime),
      ).called(1);

      // Abhaken plant die tägliche Erinnerung nicht neu und bricht sie nicht ab.
      await vm.toggleDone(task, day);
      await pumpEventQueue();
      verifyNever(
        () => notifications.syncTaskReminder(
          taskId: any(named: 'taskId'),
          title: any(named: 'title'),
          reminderTime: any(named: 'reminderTime'),
        ),
      );

      sub.close();
    });

    test('alle Aufgaben erscheinen tagesunabhängig in der Liste', () async {
      final sub = container.listen(dailyTasksViewModelProvider, (_, _) {});
      final vm = container.read(dailyTasksViewModelProvider.notifier);

      await vm.add('Erste');
      await vm.add('Zweite');
      await pumpEventQueue();

      expect(container.read(dailyTasksViewModelProvider).items.map((t) => t.title), ['Erste', 'Zweite']);
      sub.close();
    });
  });

  group('CalendarViewModel', () {
    test('Tagesnavigation hält den sichtbaren Monat synchron', () {
      final vm = CalendarViewModel();
      vm.selectDate(DateTime(2026, 7, 31));

      vm.goToNextDay();

      expect(vm.state.selectedDate, DateTime(2026, 8, 1));
      expect(vm.state.visibleMonth, DateTime(2026, 8));

      vm.goToPreviousDay();
      expect(vm.state.selectedDate, DateTime(2026, 7, 31));
      expect(vm.state.visibleMonth, DateTime(2026, 7));
      vm.dispose();
    });

    test('Monatsnavigation behält den ausgewählten Tag', () {
      final vm = CalendarViewModel();
      vm.selectDate(DateTime(2026, 7, 15));

      vm.goToNextMonth();

      expect(vm.state.visibleMonth, DateTime(2026, 8));
      expect(vm.state.selectedDate, DateTime(2026, 7, 15));
      vm.dispose();
    });
  });

  test('DailyTask.fromJson akzeptiert Timestamps und ISO-Strings', () {
    final fromString = DailyTask.fromJson({
      'title': 'T',
      'lastCompletedDate': '2026-07-02T00:00:00.000',
      'reminderTime': null,
      'createdAt': null,
    }, id: 't1');
    expect(fromString.lastCompletedDate, DateTime(2026, 7, 2));
    expect(fromString.isDoneOn(DateTime(2026, 7, 2)), isTrue);
    expect(fromString.reminderTime, isNull);
  });
}
