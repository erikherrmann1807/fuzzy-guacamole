import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuzzy_guacamole/data/services/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository(this.authService);

  Future<User?> login(String email, String password) async {
    final credential = await authService.signIn(email: email, password: password);
    return credential.user;
  }

  Future<void> logout() => authService.signOut();

  Future<void> resetPassword(String email) => authService.resetPassword(email: email);

  Future<void> updateUsername(String username) => authService.updateUsername(username: username);

  Future<void> createAccount(String email, String password, String userName) =>
      authService.createAccount(email: email, password: password, displayName: userName);

  Future<void> deleteAccount(String email, String password) =>
      authService.deleteAccount(email: email, password: password);

  Future<void> updatePassword(String newPassword) => authService.updateUserPassword(newPassword: newPassword);

  Future<bool?> validatePassword(String password) async {
    final isValid = await authService.validatePassword(password);
    return isValid;
  }
}
