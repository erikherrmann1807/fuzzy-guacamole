import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuzzy_guacamole/services/auth_service.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => authServiceGlobal.value.firebaseAuthentication);

final authStateChangesProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());