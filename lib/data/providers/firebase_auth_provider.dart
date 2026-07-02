import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/providers/firebase_firestore_provider.dart';
import 'package:fuzzy_guacamole/data/repositories/auth_repository.dart';
import 'package:fuzzy_guacamole/data/repositories/database/user_repository.dart';
import 'package:fuzzy_guacamole/data/services/auth_service.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/auth_viewmodel.dart';

final authServiceProvider = Provider((ref) => AuthService());
final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(authServiceProvider)));

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final firestore = ref.watch(fireStoreProvider);
  return AuthViewModel(
    ref.watch(authRepositoryProvider),
    userRepositoryForUid: (uid) => UserRepository(DatabaseService(fireStore: firestore, uid: uid)),
  );
});
