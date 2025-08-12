import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class FakeUser extends Mock implements User {}
class FakeAuthService extends Mock implements FirebaseAuth {}
class FakeUserCredential extends Mock implements UserCredential {}

void main() {
  late FakeAuthService mockAuth;
  late AuthService authService;
  late FakeUser fakeUser;
  late FakeUserCredential fakeUserCredential;

  const testEmail = 'testMail@gmail.com';
  const testPassword = 'secret';
  const newPassword = 'new secret';
  const testDisplayName = 'Tester';

  setUpAll(() {
    registerFallbackValue(EmailAuthProvider.credential(email: testEmail, password: testPassword));
  });
  
  setUp(() {
    mockAuth = FakeAuthService();
    authService = AuthService(firebaseAuth: mockAuth);
    fakeUser = FakeUser();
    fakeUserCredential = FakeUserCredential();
  });

  group('Test Auth Service', () {
    test('Create Account', () async {
      when(() => mockAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword
      )).thenAnswer((_) async => fakeUserCredential);

      when(() => mockAuth.currentUser).thenReturn(fakeUser);

      when(() => fakeUser.updateDisplayName(testDisplayName)).thenAnswer((_) async {});

      await authService.createAccount(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName
      );

      verify(() => mockAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword
      )).called(1);

      verify(() => fakeUser.updateDisplayName(testDisplayName)).called(1);
    });

    test('SignIn Account', () async {
      when(() => mockAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword)).thenAnswer((_) async => fakeUserCredential);

      final res = await authService.signIn(email: testEmail, password: testPassword);

      expect(res, equals(fakeUserCredential));
      verify(() => mockAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword)).called(1);
    });

    test('SignOut Account', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      await authService.signOut();
      verify(() => mockAuth.signOut()).called(1);
    });

    test('Reset Password', () async {
      when(() => mockAuth.sendPasswordResetEmail(email: testEmail)).thenAnswer((_) async {});
      await authService.resetPassword(email: testEmail);
      verify(() => mockAuth.sendPasswordResetEmail(email: testEmail)).called(1);
    });

    test('Update Username', () async {
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      when(() => fakeUser.updateDisplayName(testDisplayName)).thenAnswer((_) async {});

      await authService.updateUsername(username: testDisplayName);

      verify(() => fakeUser.updateDisplayName(testDisplayName)).called(1);
    });

    test('Update Password', () async {
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      when(() => fakeUser.updatePassword(newPassword)).thenAnswer((_) async {});

      await authService.updateUserPassword(newPassword: newPassword);

      verify(() => fakeUser.updatePassword(newPassword)).called(1);
    });

    test('Delete Account', () async {
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      when(() => fakeUser.reauthenticateWithCredential(any())).thenAnswer((_) async => fakeUserCredential);
      when(() => fakeUser.delete()).thenAnswer((_) async {});
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.deleteAccount(email: testEmail, password: testPassword);

      verify(() => fakeUser.reauthenticateWithCredential(any())).called(1);
      verify(() => fakeUser.delete()).called(1);
      verify(() => mockAuth.signOut()).called(1);
    });
  });
}