import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/providers/notification_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/database/meeting_repository.dart';

class MeetingsState {
  final bool loading;
  final List<Meeting> items;
  final String? error;

  const MeetingsState({this.loading = false, this.items = const [], this.error});

  MeetingsState copyWith({bool? loading, List<Meeting>? items, String? error}) {
    return MeetingsState(loading: loading ?? this.loading, items: items ?? this.items, error: error);
  }
}

class MeetingsViewModel extends StateNotifier<MeetingsState> {
  final Ref ref;
  StreamSubscription<List<Meeting>>? _sub;

  MeetingsViewModel(this.ref) : super(const MeetingsState()) {
    ref.listen<MeetingRepository?>(
      meetingRepositoryProvider,
      (prev, next) => _resubscribe(next),
      fireImmediately: true,
    );
  }

  void _resubscribe(MeetingRepository? repo) {
    _sub?.cancel();
    if (repo == null) {
      state = const MeetingsState();
      return;
    }
    state = state.copyWith(loading: true, error: null);
    _sub = repo.watchAll().listen(
      (items) => state = state.copyWith(loading: false, items: items),
      onError: (Object e, StackTrace st) => state = state.copyWith(loading: false, error: e.toString()),
    );
  }

  Future<void> refresh() async {
    final repo = ref.read(meetingRepositoryProvider);
    if (repo == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final data = await repo.fetchOnce();
      state = state.copyWith(loading: false, items: data);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> add(Meeting m) => _mutate((repo) async {
    final id = await repo.add(m);
    await _syncReminder(m.copyWith(meetingId: id));
  });

  Future<bool> update(String id, Meeting m) => _mutate((repo) async {
    await repo.update(id, m);
    await _syncReminder(m.copyWith(meetingId: id));
  });

  Future<bool> remove(String id) => _mutate((repo) async {
    await repo.remove(id);
    await _cancelReminder(id);
  });

  /// Erinnerungen dürfen das Speichern nie scheitern lassen –
  /// Notification-Fehler werden nur geloggt.
  Future<void> _syncReminder(Meeting meeting) async {
    try {
      await ref.read(notificationServiceProvider).syncMeetingReminder(meeting);
    } catch (e) {
      debugPrint('Erinnerung konnte nicht geplant werden: $e');
    }
  }

  Future<void> _cancelReminder(String meetingId) async {
    try {
      await ref.read(notificationServiceProvider).cancelMeetingReminder(meetingId);
    } catch (e) {
      debugPrint('Erinnerung konnte nicht abgebrochen werden: $e');
    }
  }

  /// Führt eine Schreiboperation mit einheitlichem Error-Handling aus.
  /// Die Datenaktualisierung selbst kommt über den Snapshot-Stream.
  Future<bool> _mutate(Future<void> Function(MeetingRepository repo) action) async {
    final repo = ref.read(meetingRepositoryProvider);
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
