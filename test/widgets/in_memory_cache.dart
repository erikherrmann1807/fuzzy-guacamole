import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/services/local_cache_service.dart';

/// In-Memory-Ersatz für den Hive-Cache in Widget-Tests
/// (echtes Datei-I/O läuft in der FakeAsync-Zone nicht zuverlässig).
class InMemoryCache extends LocalCacheService {
  InMemoryCache() : super(uid: 'widget_test');

  final Map<String, Meeting> meetings = {};
  final Map<String, DailyTask> tasks = {};

  @override
  Future<List<Meeting>> readMeetings() async => meetings.values.toList();

  @override
  Future<void> writeMeetings(List<Meeting> items) async {
    meetings
      ..clear()
      ..addEntries([
        for (final m in items)
          if (m.meetingId != null) MapEntry(m.meetingId!, m),
      ]);
  }

  @override
  Future<void> upsertMeeting(String id, Meeting meeting) async => meetings[id] = meeting;

  @override
  Future<void> removeMeeting(String id) async => meetings.remove(id);

  @override
  Future<List<DailyTask>> readTasks() async => tasks.values.toList();

  @override
  Future<void> writeTasks(List<DailyTask> items) async {
    tasks
      ..clear()
      ..addEntries([
        for (final t in items)
          if (t.taskId != null) MapEntry(t.taskId!, t),
      ]);
  }

  @override
  Future<void> upsertTask(String id, DailyTask task) async => tasks[id] = task;

  @override
  Future<void> removeTask(String id) async => tasks.remove(id);

  @override
  Future<void> clearAll() async {
    meetings.clear();
    tasks.clear();
  }
}
