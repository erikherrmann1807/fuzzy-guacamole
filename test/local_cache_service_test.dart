import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/services/local_cache_service.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:hive/hive.dart';

Meeting testMeeting(String id, {String name = 'Meeting'}) {
  return Meeting(
    meetingId: id,
    eventName: name,
    description: 'desc',
    start: DateTime(2026, 7, 2, 10),
    end: DateTime(2026, 7, 2, 11),
    labelColor: MyColors.highLabel,
    priority: 'High',
    isAllDay: false,
    reminderMinutes: 15,
  );
}

void main() {
  late Directory tempDir;
  late LocalCacheService cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_cache_test');
    Hive.init(tempDir.path);
    cache = LocalCacheService(uid: 'user_123');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('Meetings-Cache', () {
    test('Roundtrip: geschriebene Meetings kommen identisch zurück', () async {
      await cache.writeMeetings([testMeeting('m1'), testMeeting('m2', name: 'Zweites')]);

      final meetings = await cache.readMeetings();

      expect(meetings, hasLength(2));
      final m1 = meetings.singleWhere((m) => m.meetingId == 'm1');
      expect(m1.eventName, 'Meeting');
      expect(m1.start, DateTime(2026, 7, 2, 10));
      expect(m1.end, DateTime(2026, 7, 2, 11));
      expect(m1.reminderMinutes, 15);
    });

    test('writeMeetings ersetzt den kompletten Bestand', () async {
      await cache.writeMeetings([testMeeting('m1')]);
      await cache.writeMeetings([testMeeting('m2')]);

      final meetings = await cache.readMeetings();
      expect(meetings.map((m) => m.meetingId), ['m2']);
    });

    test('upsert und remove wirken auf einzelne Einträge', () async {
      await cache.upsertMeeting('m1', testMeeting('m1'));
      await cache.upsertMeeting('m1', testMeeting('m1', name: 'Geändert'));
      await cache.upsertMeeting('m2', testMeeting('m2'));
      await cache.removeMeeting('m2');

      final meetings = await cache.readMeetings();
      expect(meetings, hasLength(1));
      expect(meetings.single.eventName, 'Geändert');
    });

    test('Caches verschiedener Nutzer sind getrennt', () async {
      await cache.writeMeetings([testMeeting('m1')]);
      final otherCache = LocalCacheService(uid: 'other_user');
      expect(await otherCache.readMeetings(), isEmpty);
    });
  });

  group('Tasks-Cache', () {
    final day = DateTime(2026, 7, 2);

    DailyTask task(String id, {DateTime? date, bool isDone = false, DateTime? createdAt}) {
      return DailyTask(
        taskId: id,
        title: 'Task $id',
        date: date ?? day,
        isDone: isDone,
        reminderTime: DateTime(2026, 7, 2, 9),
        createdAt: createdAt,
      );
    }

    test('readTasksForDay liefert nur Aufgaben des Tages, sortiert nach createdAt', () async {
      await cache.writeTasksForDay(day, [
        task('t2', createdAt: DateTime(2026, 7, 1, 12)),
        task('t1', createdAt: DateTime(2026, 7, 1, 8)),
      ]);
      await cache.upsertTask('t3', task('t3', date: DateTime(2026, 7, 3)));

      final tasks = await cache.readTasksForDay(day);

      expect(tasks.map((t) => t.taskId), ['t1', 't2']);
      expect(tasks.first.reminderTime, DateTime(2026, 7, 2, 9));
    });

    test('writeTasksForDay ersetzt nur die Aufgaben dieses Tages', () async {
      await cache.upsertTask('anderer', task('anderer', date: DateTime(2026, 7, 3)));
      await cache.writeTasksForDay(day, [task('t1')]);
      await cache.writeTasksForDay(day, [task('t2')]);

      expect((await cache.readTasksForDay(day)).map((t) => t.taskId), ['t2']);
      expect((await cache.readTasksForDay(DateTime(2026, 7, 3))).map((t) => t.taskId), ['anderer']);
    });

    test('clearAll entfernt Meetings und Tasks des Nutzers', () async {
      await cache.writeMeetings([testMeeting('m1')]);
      await cache.writeTasksForDay(day, [task('t1')]);

      await cache.clearAll();

      expect(await cache.readMeetings(), isEmpty);
      expect(await cache.readTasksForDay(day), isEmpty);
    });

    test('serverTimestamp-Platzhalter (FieldValue) wird als null gecacht', () async {
      // createdAt == null -> toJson enthält FieldValue.serverTimestamp().
      await cache.upsertTask('t1', task('t1'));

      final tasks = await cache.readTasksForDay(day);
      expect(tasks.single.createdAt, isNull);
    });
  });
}
