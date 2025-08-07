import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

ValueNotifier<AuthService> authServiceGlobal = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({required String email, required String password}) async {
    return await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> createAccount({required String email, required String password, required String displayName}) async {
    await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    await firebaseAuth.currentUser?.updateDisplayName(displayName);
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required username}) async {
    await currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({required String email, required String password}) async {
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  Future<void> updateUserPassword({required String newPassword}) async {
    await currentUser!.updatePassword(newPassword);
  }

  Future<bool> validatePassword(String password) async {
    AuthCredential credential = EmailAuthProvider.credential(email: currentUser!.email!, password: password);
    try {
      var authResult = await currentUser!.reauthenticateWithCredential(credential);
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
