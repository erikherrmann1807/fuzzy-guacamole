import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/models/appointment_model.dart';
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

  group('Test database operations', (){
    test('Get all Meetings from specific User', () async {
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

      final meetings = await dbService.meetingsStream.first;

      expect(meetings, hasLength(2));
      expect(
        meetings.map((m) => m.eventName),
        containsAll(['eventName', 'Test']),
      );
    });

    test('Add a new Meeting', () async {
      final initialMeetings = await dbService.meetingsStream.first;
      expect(initialMeetings, isEmpty);

      final newMeeting = Meeting(
        eventName: 'New Meeting',
        description: 'New Meeting added',
        start: DateTime(2025, 8, 8, 11, 30),
        end: DateTime(2025, 8, 8, 13, 30),
        backgroundColor: Colors.black,
        isAllDay: false,
      );

      await dbService.addMeeting(newMeeting);

      final updatedMeetings = await dbService.meetingsStream.first;

      expect(updatedMeetings, hasLength(1));
      expect(updatedMeetings.first.eventName, 'New Meeting');
    });

    test('Delete an existing Meeting', () async {
      final meeting = Meeting(
        eventName: 'New Meeting',
        description: 'New Meeting added',
        start: DateTime(2025, 8, 8, 11, 30),
        end: DateTime(2025, 8, 8, 13, 30),
        backgroundColor: Colors.black,
        isAllDay: false,
      );

      await dbService.addMeeting(meeting);
      final [addedMeeting] = await dbService.meetingsStream.first;
      expect(addedMeeting.eventName, 'New Meeting');

      await dbService.deleteMeeting(addedMeeting.meetingId);
      final updatedMeetings = await dbService.meetingsStream.first;
      expect(updatedMeetings, isEmpty);
    });

    test('Update an existing Meeting', () async {
      final originalMeeting = Meeting(
        eventName: 'New Meeting',
        description: 'New Meeting added',
        start: DateTime(2025, 8, 8, 11, 30),
        end: DateTime(2025, 8, 8, 13, 30),
        backgroundColor: Colors.black,
        isAllDay: false,
      );

      await dbService.addMeeting(originalMeeting);
      final [addedMeeting] = await dbService.meetingsStream.first;

      final updatedMeeting = Meeting(
        eventName: 'Updated Meeting',
        description: 'Meeting updated',
        start: DateTime(2025, 8, 9, 12, 30),
        end: DateTime(2025, 8, 9, 15, 30),
        backgroundColor: Colors.blue,
        isAllDay: false,
      );

      await dbService.updateMeeting(addedMeeting.meetingId, updatedMeeting);
      final [newMeeting] = await dbService.meetingsStream.first;
      expect(newMeeting.eventName, 'Updated Meeting');
    });
  });
}
