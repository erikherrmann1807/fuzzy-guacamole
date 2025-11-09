import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/database/meeting_repository.dart';
import 'package:fuzzy_guacamole/data/repositories/database/user_repository.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';

final fireStoreProvider = Provider((_) => FirebaseFirestore.instance);

// DatabaseService nur, wenn ein User vorhanden ist
final databaseServiceProvider = Provider<DatabaseService?>((ref) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.uid));
  if (uid == null) return null;
  final db = ref.watch(fireStoreProvider);
  return DatabaseService(fireStore: db, uid: uid); // deine uid-basierte Version
});

final meetingRepositoryProvider = Provider<MeetingRepository?>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db == null ? null : MeetingRepository(db);
});

final userRepositoryProvider = Provider<UserRepository?>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return db == null ? null : UserRepository(db);
});
