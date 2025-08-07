import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/constants/database_refs.dart';
import 'package:fuzzy_guacamole/services/database_service.dart';
import 'package:fuzzy_guacamole/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class FakeUser extends Mock implements User {}
class FakeAuthService extends Mock implements AuthService {}

void main() {
  late FakeFirebaseFirestore mockFireStore;
  late FakeAuthService mockAuth;
  late DatabaseService dbService;

  const testUid = 'user_123';

  setUp(() {
    mockFireStore = FakeFirebaseFirestore();
    mockAuth = FakeAuthService();

    final fakeUser = FakeUser();
    when(() => fakeUser.uid).thenReturn(testUid);
    when(() => mockAuth.currentUser).thenReturn(fakeUser);

    dbService = DatabaseService(
      fireStore: mockFireStore,
      authService: mockAuth
    );
  });

  test('meetingsStream liefert die Meetings des aktuellen Nutzers', () async {
    // Arrange: Zwei Dummy-Meetins im Mock-FireStore erzeugen
    final ref = mockFireStore
        .collection(USER_COLLECTION_REF)
        .doc(testUid)
        .collection(MEETING_COLLECTION_REF);

    await ref.add({
      'eventName': 'eventName',
      'description': 'description',
      'start': DateTime(2025, 8, 21, 10, 30).toString(),
      'end': DateTime(2025, 8, 21, 11, 30).toString(),
      'backgroundColor': Colors.blue.toARGB32(),
      'isAllDay': false,
    });

    await ref.add({
      'eventName': 'Test',
      'description': 'Hilfe',
      'start': DateTime(2025, 8, 23, 10, 30).toString(),
      'end': DateTime(2025, 8, 23, 11, 30).toString(),
      'backgroundColor': Colors.red.toARGB32(),
      'isAllDay': true,
    });

    // Act: das erste Event aus dem Stream
    final meetings = await dbService.meetingsStream.first;

    // Assert: Wir erhalten zwei Meeting-Objekte mit den korrekten Event Namen
    expect(meetings, hasLength(2));
    expect(
    meetings.map((m) => m.eventName),
    containsAll(['eventName', 'Test']),
    );
  });
}
