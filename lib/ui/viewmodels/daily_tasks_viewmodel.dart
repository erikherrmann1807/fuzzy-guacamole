import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/daily_task_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/providers/notification_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/database/task_repository.dart';

class DailyTasksState {
  final bool loading;
  final List<DailyTask> items;
  final String? error;

  const DailyTasksState({this.loading = false, this.items = const [], this.error});

  DailyTasksState copyWith({bool? loading, List<DailyTask>? items, String? error}) {
    return DailyTasksState(loading: loading ?? this.loading, items: items ?? this.items, error: error);
  }
}

/// ViewModel für die Liste der wiederkehrenden Daily Tasks.
class DailyTasksViewModel extends StateNotifier<DailyTasksState> {
  final Ref ref;
  StreamSubscription<List<DailyTask>>? _sub;

  DailyTasksViewModel(this.ref) : super(const DailyTasksState()) {
    ref.listen<TaskRepository?>(
      taskRepositoryProvider,
      (prev, next) => _resubscribe(next),
      fireImmediately: true,
    );
  }

  void _resubscribe(TaskRepository? repo) {
    _sub?.cancel();
    if (repo == null) {
      state = const DailyTasksState();
      return;
    }
    state = state.copyWith(loading: true, error: null);
    _sub = repo.watchTasks().listen(
      (items) => state = state.copyWith(loading: false, items: items),
      onError: (Object e, StackTrace st) => state = state.copyWith(loading: false, error: e.toString()),
    );
  }

  Future<bool> add(String title, {DateTime? reminderTime}) {
    final task = DailyTask(title: title, reminderTime: reminderTime);
    return _mutate((repo) async {
      final id = await repo.add(task);
      await _syncReminder(task.copyWith(taskId: id));
    });
  }

  /// Hakt die Aufgabe für [day] ab bzw. hebt die Erledigung wieder auf.
  /// Die tägliche Erinnerung bleibt davon unberührt – sie feuert unabhängig
  /// vom Erledigt-Status jeden Tag erneut.
  Future<bool> toggleDone(DailyTask task, DateTime day) {
    final id = task.taskId;
    if (id == null) return Future.value(false);
    final updated = task.isDoneOn(day)
        ? task.copyWith(clearCompleted: true)
        : task.copyWith(lastCompletedDate: DateTime(day.year, day.month, day.day));
    return _mutate((repo) => repo.update(id, updated));
  }

  Future<bool> remove(DailyTask task) {
    final id = task.taskId;
    if (id == null) return Future.value(false);
    return _mutate((repo) async {
      await repo.remove(id);
      await _cancelReminder(id);
    });
  }

  /// Erinnerungen dürfen die Schreiboperation nie scheitern lassen –
  /// Notification-Fehler werden nur geloggt. Die Erinnerung feuert täglich
  /// zur gewählten Uhrzeit, unabhängig vom Erledigt-Status.
  Future<void> _syncReminder(DailyTask task) async {
    final id = task.taskId;
    if (id == null) return;
    try {
      await ref
          .read(notificationServiceProvider)
          .syncTaskReminder(taskId: id, title: task.title, reminderTime: task.reminderTime);
    } catch (e) {
      debugPrint('Task-Erinnerung konnte nicht geplant werden: $e');
    }
  }

  Future<void> _cancelReminder(String taskId) async {
    try {
      await ref.read(notificationServiceProvider).cancelTaskReminder(taskId);
    } catch (e) {
      debugPrint('Task-Erinnerung konnte nicht abgebrochen werden: $e');
    }
  }

  Future<bool> _mutate(Future<void> Function(TaskRepository repo) action) async {
    final repo = ref.read(taskRepositoryProvider);
    if (repo == null) return false;
    try {
      await action(repo);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
