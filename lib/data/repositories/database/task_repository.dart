import 'package:flutter/foundation.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/data/services/local_cache_service.dart';

/// Read-Through-/Write-Back-Repository für Daily Tasks
/// (gleiche Strategie wie beim [MeetingRepository]: Cache zuerst,
/// Firestore-Snapshots als Source of Truth).
class TaskRepository {
  final DatabaseService db;
  final LocalCacheService cache;
  TaskRepository(this.db, this.cache);

  /// Aufgaben eines Kalendertages (Cache sofort, danach live via Firestore).
  Stream<List<DailyTask>> watchDay(DateTime day) async* {
    try {
      final cached = await cache.readTasksForDay(day);
      if (cached.isNotEmpty) yield cached;
    } catch (e) {
      debugPrint('Task-Cache konnte nicht gelesen werden: $e');
    }
    yield* db.tasksForDayStream(day).map((items) {
      _guardCache(() => cache.writeTasksForDay(day, items));
      return items;
    });
  }

  /// Liefert die generierte Dokument-ID der neuen Aufgabe.
  Future<String> add(DailyTask task) async {
    final id = await db.addTask(task);
    await _guardCache(() => cache.upsertTask(id, task.copyWith(taskId: id)));
    return id;
  }

  Future<void> update(String id, DailyTask task) async {
    await db.updateTask(id, task);
    await _guardCache(() => cache.upsertTask(id, task.copyWith(taskId: id)));
  }

  Future<void> remove(String id) async {
    await db.deleteTask(id);
    await _guardCache(() => cache.removeTask(id));
  }

  /// Cache-Fehler dürfen Lese-/Schreiboperationen nie scheitern lassen.
  Future<void> _guardCache(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      debugPrint('Task-Cache konnte nicht aktualisiert werden: $e');
    }
  }
}
