import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/repositories/auth_repository.dart';
import 'package:fuzzy_guacamole/data/services/auth_service.dart';
import 'package:fuzzy_guacamole/ui/viewmodels/auth_viewmodel.dart';

/*
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => authServiceGlobal.value.firebaseAuthentication);

final authStateChangesProvider = StreamProvider<User?>((ref) => ref.watch(firebaseAuthProvider).authStateChanges());
 */

final authServiceProvider = Provider((ref) => AuthService());
final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.watch(authServiceProvider)));

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
      return AuthViewModel(ref.watch(authRepositoryProvider));
    });