import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:hive/hive.dart';

/// Lokaler Cache (Hive) pro Nutzer für Meetings und Daily Tasks.
///
/// Zweck: Daten sofort beim App-Start anzeigen (auch offline, bevor
/// Firestore initialisiert ist). Die Repositories nutzen ihn als
/// Read-Through-/Write-Back-Schicht; Firestore-Snapshots sind die
/// "Source of Truth" und überschreiben den Cache (Last-Write-Wins).
///
/// Persistiert werden JSON-kompatible Maps: `Timestamp`-Werte werden als
/// ISO-8601-Strings abgelegt, die die Modelle beim Lesen wieder verstehen.
class LocalCacheService {
  final String uid;
  LocalCacheService({required this.uid});

  String get _meetingsBoxName => 'meetings_$uid';
  String get _tasksBoxName => 'tasks_$uid';

  Future<Box<Map>> _box(String name) async =>
      Hive.isBoxOpen(name) ? Hive.box<Map>(name) : await Hive.openBox<Map>(name);

  // --- Meetings ---

  Future<List<Meeting>> readMeetings() async {
    final box = await _box(_meetingsBoxName);
    return box
        .toMap()
        .entries
        .map((e) => Meeting.fromJson(Map<String, dynamic>.from(e.value), id: e.key as String))
        .toList();
  }

  /// Ersetzt den kompletten Meeting-Bestand (nach einem Firestore-Snapshot).
  Future<void> writeMeetings(List<Meeting> meetings) async {
    final box = await _box(_meetingsBoxName);
    await box.clear();
    await box.putAll({
      for (final m in meetings)
        if (m.meetingId != null) m.meetingId!: _toCacheJson(m.toJson()),
    });
  }

  Future<void> upsertMeeting(String id, Meeting meeting) async {
    final box = await _box(_meetingsBoxName);
    await box.put(id, _toCacheJson(meeting.toJson()));
  }

  Future<void> removeMeeting(String id) async {
    final box = await _box(_meetingsBoxName);
    await box.delete(id);
  }

  // --- Daily Tasks ---

  Future<List<DailyTask>> readTasksForDay(DateTime day) async {
    final box = await _box(_tasksBoxName);
    final normalized = DateTime(day.year, day.month, day.day);
    final tasks = box
        .toMap()
        .entries
        .map((e) => DailyTask.fromJson(Map<String, dynamic>.from(e.value), id: e.key as String))
        .where((t) => t.date.year == normalized.year && t.date.month == normalized.month && t.date.day == normalized.day)
        .toList();
    tasks.sort((a, b) {
      final aTime = a.createdAt;
      final bTime = b.createdAt;
      if (aTime == null || bTime == null) return aTime == null ? (bTime == null ? 0 : 1) : -1;
      return aTime.compareTo(bTime);
    });
    return tasks;
  }

  /// Ersetzt alle Aufgaben eines Tages (nach einem Firestore-Snapshot).
  Future<void> writeTasksForDay(DateTime day, List<DailyTask> tasks) async {
    final box = await _box(_tasksBoxName);
    final existing = await readTasksForDay(day);
    await box.deleteAll(existing.map((t) => t.taskId).whereType<String>());
    await box.putAll({
      for (final t in tasks)
        if (t.taskId != null) t.taskId!: _toCacheJson(t.toJson()),
    });
  }

  Future<void> upsertTask(String id, DailyTask task) async {
    final box = await _box(_tasksBoxName);
    await box.put(id, _toCacheJson(task.toJson()));
  }

  Future<void> removeTask(String id) async {
    final box = await _box(_tasksBoxName);
    await box.delete(id);
  }

  /// Entfernt alle lokalen Daten des Nutzers (z. B. bei Account-Löschung).
  Future<void> clearAll() async {
    for (final name in [_meetingsBoxName, _tasksBoxName]) {
      final box = await _box(name);
      await box.clear();
    }
  }

  /// Firestore-Spezialtypen in Hive-taugliche Werte übersetzen:
  /// `Timestamp` -> ISO-String, `FieldValue` (serverTimestamp) -> null.
  static Map<String, dynamic> _toCacheJson(Map<String, dynamic> json) {
    return json.map((key, value) {
      if (value is Timestamp) return MapEntry(key, value.toDate().toIso8601String());
      if (value is FieldValue) return MapEntry(key, null);
      return MapEntry(key, value);
    });
  }
}
