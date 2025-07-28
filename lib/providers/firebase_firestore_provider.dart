import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/providers/firebase_auth_provider.dart';
import 'package:fuzzy_guacamole/services/database_service.dart';

final firestoreProvider = Provider<DatabaseService?>((ref) {
  final auth = ref.watch(authStateChangesProvider);
  DatabaseService databaseService = DatabaseService();

  if (auth.value?.uid != null) {
    return databaseService;
  }
  return null;
});