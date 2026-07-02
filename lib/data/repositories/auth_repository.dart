import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuzzy_guacamole/data/services/auth_service.dart';

/// Vermittelt zwischen ViewModels und [AuthService].
class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  User? get currentUser => authService.currentUser;

  Stream<User?> get authStateChanges => authService.authStateChanges;

  Future<User?> login(String email, String password) async {
    final credential = await authService.signIn(email: email, password: password);
    return credential.user;
  }

  Future<void> logout() => authService.signOut();

  Future<void> resetPassword(String email) => authService.resetPassword(email: email);

  Future<void> updateUsername(String username) => authService.updateUsername(username: username);

  Future<User?> createAccount(String email, String password, String userName) async {
    final credential = await authService.createAccount(email: email, password: password, displayName: userName);
    return credential.user;
  }

  Future<void> deleteAccount(String email, String password) =>
      authService.deleteAccount(email: email, password: password);

  Future<void> updatePassword(String newPassword) => authService.updateUserPassword(newPassword: newPassword);

  Future<bool> validatePassword(String password) => authService.validatePassword(password);
}
