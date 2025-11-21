import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/data/repositories/auth_repository.dart';

class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isValid;

  const AuthState({this.isLoading = false, this.user, this.error, this.isValid = false});

  AuthState copyWith({bool? isLoading, User? user, String? error, bool? isValid}) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    user: user ?? this.user,
    error: error,
    isValid: isValid ?? this.isValid,
  );
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthViewModel(this.repository) : super(const AuthState()) {
    init();
  }

  Future<void> init() async {
    final currentUser = repository.authService.currentUser;
    if (currentUser != null) {
      state = state.copyWith(user: currentUser);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await repository.login(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = const AuthState(user: null);
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUsername(String username) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.updateUsername(username);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createAccount(String email, String password, String userName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.createAccount(email, password, userName);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAccount(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.deleteAccount(email, password);
      state = state.copyWith(isLoading: false, user: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> validatePassword(String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isValid = await repository.validatePassword(password);
      state = state.copyWith(isLoading: false, isValid: isValid);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await repository.updatePassword(newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
