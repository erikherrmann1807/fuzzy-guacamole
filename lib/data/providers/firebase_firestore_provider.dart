import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/database/meeting_repository.dart';
import 'package:fuzzy_guacamole/data/repositories/database/user_repository.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/meetings_viewmodel.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/profile_viewmodel.dart';

final fireStoreProvider = Provider((_) => FirebaseFirestore.instance);

/// Nutzergebundener Firestore-Zugriff; `null` solange niemand angemeldet ist.
final databaseServiceProvider = Provider<DatabaseService?>((ref) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.uid));
  if (uid == null) return null;
  final db = ref.watch(fireStoreProvider);
  return DatabaseService(fireStore: db, uid: uid);
});

final meetingRepositoryProvider = Provider<MeetingRepository?>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db == null ? null : MeetingRepository(db);
});

final userRepositoryProvider = Provider<UserRepository?>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db == null ? null : UserRepository(db);
});

final meetingsViewModelProvider = StateNotifierProvider<MeetingsViewModel, MeetingsState>(
  (ref) => MeetingsViewModel(ref),
);

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) => ProfileViewModel(ref));
