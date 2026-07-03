import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/repositories/database/meeting_repository.dart';
import 'package:fuzzy_guacamole/data/repositories/database/task_repository.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/data/services/local_cache_service.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:hive/hive.dart';

Meeting testMeeting({String? id, String name = 'Meeting'}) {
  return Meeting(
    meetingId: id,
    eventName: name,
    description: '',
    start: DateTime(2026, 7, 2, 10),
    end: DateTime(2026, 7, 2, 11),
    labelColor: MyColors.highLabel,
    priority: 'High',
    isAllDay: false,
  );
}

void main() {
  late Directory tempDir;
  late FakeFirebaseFirestore firestore;
  late DatabaseService db;
  late LocalCacheService cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_repo_test');
    Hive.init(tempDir.path);
    firestore = FakeFirebaseFirestore();
    db = DatabaseService(fireStore: firestore, uid: 'user_123');
    cache = LocalCacheService(uid: 'user_123');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('MeetingRepository (Read-Through/Write-Back)', () {
    test('watchAll liefert zuerst den Cache, dann die Firestore-Daten', () async {
      // Cache aus "früherer Sitzung": ein alter Stand.
      await cache.writeMeetings([testMeeting(id: 'cached', name: 'Aus dem Cache')]);
      // Firestore hat inzwischen andere Daten.
      final repo = MeetingRepository(db, cache);
      await repo.add(testMeeting(name: 'Live'));

      final emissions = await repo.watchAll().take(2).toList();

      expect(emissions[0].map((m) => m.eventName), contains('Aus dem Cache'));
      expect(emissions[1].map((m) => m.eventName), contains('Live'));
    });

    test('Firestore-Snapshots aktualisieren den Cache (Server gewinnt)', () async {
      await cache.writeMeetings([testMeeting(id: 'veraltet', name: 'Veraltet')]);
      final repo = MeetingRepository(db, cache);
      final id = await repo.add(testMeeting(name: 'Aktuell'));

      // Snapshot konsumieren -> Cache wird write-through aktualisiert.
      await repo.watchAll().take(2).toList();
      // Cache-Write ist fire-and-forget: kurz auf die Event-Loop warten.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final cached = await cache.readMeetings();
      expect(cached.map((m) => m.meetingId), [id]);
      expect(cached.single.eventName, 'Aktuell');
    });

    test('add schreibt sofort in den Cache (Write-Back)', () async {
      final repo = MeetingRepository(db, cache);
      final id = await repo.add(testMeeting(name: 'Neu'));

      final cached = await cache.readMeetings();
      expect(cached.single.meetingId, id);
      expect(cached.single.eventName, 'Neu');
    });

    test('update und remove halten den Cache konsistent', () async {
      final repo = MeetingRepository(db, cache);
      final id = await repo.add(testMeeting(name: 'Neu'));

      await repo.update(id, testMeeting(name: 'Geändert'));
      expect((await cache.readMeetings()).single.eventName, 'Geändert');

      await repo.remove(id);
      expect(await cache.readMeetings(), isEmpty);
    });
  });

  group('TaskRepository (Read-Through/Write-Back)', () {
    final day = DateTime(2026, 7, 2);

    test('watchTasks liefert zuerst den Cache, dann die Firestore-Daten', () async {
      await cache.writeTasks([DailyTask(taskId: 'cached', title: 'Aus dem Cache')]);
      final repo = TaskRepository(db, cache);
      await repo.add(DailyTask(title: 'Live'));

      final emissions = await repo.watchTasks().take(2).toList();

      // Erste Emission aus dem Cache (enthält durch das Write-Back auch 'Live'),
      // zweite aus Firestore (kennt den reinen Cache-Eintrag nicht).
      expect(emissions[0].map((t) => t.title), contains('Aus dem Cache'));
      expect(emissions[1].map((t) => t.title), ['Live']);
    });

    test('add/update/remove halten den Cache konsistent', () async {
      final repo = TaskRepository(db, cache);
      final id = await repo.add(DailyTask(title: 'Einkaufen'));

      expect((await cache.readTasks()).single.title, 'Einkaufen');

      await repo.update(id, DailyTask(taskId: id, title: 'Einkaufen', lastCompletedDate: day));
      expect((await cache.readTasks()).single.isDoneOn(day), isTrue);

      await repo.remove(id);
      expect(await cache.readTasks(), isEmpty);
    });

    test('watchTasks liefert alle Aufgaben tagesunabhängig', () async {
      final repo = TaskRepository(db, cache);
      await repo.add(DailyTask(title: 'Erste'));
      await repo.add(DailyTask(title: 'Zweite'));

      final tasks = await repo.watchTasks().take(2).last;
      expect(tasks.map((t) => t.title), ['Erste', 'Zweite']);
    });
  });
}
