import 'package:firebase_auth/firebase_auth.dart';

/// Kapselt alle FirebaseAuth-Zugriffe.
class AuthService {
  final FirebaseAuth firebaseAuthentication;

  AuthService({FirebaseAuth? firebaseAuth}) : firebaseAuthentication = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => firebaseAuthentication.currentUser;

  Stream<User?> get authStateChanges => firebaseAuthentication.authStateChanges();

  Future<UserCredential> signIn({required String email, required String password}) {
    return firebaseAuthentication.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => firebaseAuthentication.signOut();

  Future<void> resetPassword({required String email}) => firebaseAuthentication.sendPasswordResetEmail(email: email);

  Future<void> updateUsername({required String username}) async {
    final user = _requireUser();
    await user.updateDisplayName(username);
  }

  /// Legt den Account an und setzt direkt den Anzeigenamen.
  /// Firebase meldet den Nutzer dabei automatisch an.
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await firebaseAuthentication.createUserWithEmailAndPassword(email: email, password: password);
    await updateUsername(username: displayName);
    return credential;
  }

  Future<void> deleteAccount({required String email, required String password}) async {
    final user = _requireUser();
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
    await user.delete();
    await firebaseAuthentication.signOut();
  }

  Future<void> updateUserPassword({required String newPassword}) async {
    final user = _requireUser();
    await user.updatePassword(newPassword);
  }

  Future<bool> validatePassword(String password) async {
    final user = _requireUser();
    final email = user.email;
    if (email == null) return false;
    final credential = EmailAuthProvider.credential(email: email, password: password);
    try {
      final authResult = await user.reauthenticateWithCredential(credential);
      return authResult.user != null;
    } on FirebaseAuthException {
      return false;
    }
  }

  User _requireUser() {
    final user = currentUser;
    if (user == null) {
      throw StateError('Kein Nutzer angemeldet.');
    }
    return user;
  }
}
