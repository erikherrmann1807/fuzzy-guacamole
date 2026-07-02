import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/models/user_model.dart';
import 'package:fuzzy_guacamole/data/repositories/auth_repository.dart';
import 'package:fuzzy_guacamole/data/repositories/database/user_repository.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isValid;

  const AuthState({this.isLoading = false, this.user, this.error, this.isValid = false});

  /// `error` wird bewusst nicht übernommen: jeder Übergang setzt ihn neu
  /// oder löscht ihn. [clearUser] erlaubt das explizite Abmelden im State.
  AuthState copyWith({bool? isLoading, User? user, bool clearUser = false, String? error, bool? isValid}) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    user: clearUser ? null : (user ?? this.user),
    error: error,
    isValid: isValid ?? this.isValid,
  );
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository repository;

  /// Erzeugt ein [UserRepository] für eine frisch angelegte UID, damit das
  /// Profildokument direkt bei der Registrierung geschrieben werden kann.
  final UserRepository Function(String uid) userRepositoryForUid;

  StreamSubscription<User?>? _authSub;

  AuthViewModel(this.repository, {required this.userRepositoryForUid})
    : super(AuthState(user: repository.currentUser)) {
    _authSub = repository.authStateChanges.listen((user) {
      state = state.copyWith(user: user, clearUser: user == null);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<bool> login(String email, String password) {
    return _run(() async {
      final user = await repository.login(email, password);
      state = state.copyWith(user: user);
    });
  }

  Future<void> logout() async {
    await repository.logout();
    state = const AuthState();
  }

  Future<bool> resetPassword(String email) => _run(() => repository.resetPassword(email));

  Future<bool> updateUsername(String username) => _run(() => repository.updateUsername(username));

  /// Legt den Auth-Account an und erzeugt direkt das zugehörige
  /// Profildokument – ohne auf Provider-Rebuilds warten zu müssen.
  Future<bool> createAccount(String email, String password, String userName) {
    return _run(() async {
      final user = await repository.createAccount(email, password, userName);
      if (user != null) {
        await userRepositoryForUid(user.uid).create(Member(userName: userName, email: email));
      }
      state = state.copyWith(user: user);
    });
  }

  Future<bool> deleteAccount(String email, String password) {
    return _run(() async {
      await repository.deleteAccount(email, password);
      state = state.copyWith(clearUser: true);
    });
  }

  Future<bool> validatePassword(String password) {
    return _run(() async {
      final isValid = await repository.validatePassword(password);
      state = state.copyWith(isValid: isValid);
    });
  }

  Future<bool> updatePassword(String newPassword) => _run(() => repository.updatePassword(newPassword));

  /// Führt eine Auth-Aktion mit einheitlichem Loading-/Error-Handling aus.
  /// Liefert `true` bei Erfolg.
  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await action();
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message ?? e.code);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
