import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';

class TaskRepository {
  final DatabaseService db;
  TaskRepository(this.db);

  /// Aufgaben eines Kalendertages (live über Firestore-Snapshots).
  Stream<List<DailyTask>> watchDay(DateTime day) => db.tasksForDayStream(day);

  /// Liefert die generierte Dokument-ID der neuen Aufgabe.
  Future<String> add(DailyTask task) => db.addTask(task);
  Future<void> update(String id, DailyTask task) => db.updateTask(id, task);
  Future<void> remove(String id) => db.deleteTask(id);
}
