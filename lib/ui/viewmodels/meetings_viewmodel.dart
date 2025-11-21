import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
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
      onError: (e, st) => state = state.copyWith(loading: false, error: e.toString()),
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

  Future<void> add(Meeting m) async {
    final repo = ref.read(meetingRepositoryProvider);
    if (repo != null) await repo.add(m);
  }

  Future<void> update(String id, Meeting m) async {
    final repo = ref.read(meetingRepositoryProvider);
    if (repo != null) await repo.update(id, m);
  }

  Future<void> remove(String id) async {
    final repo = ref.read(meetingRepositoryProvider);
    if (repo != null) await repo.remove(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
