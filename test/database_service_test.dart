import 'package:flutter_test/flutter_test.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/services/database_service.dart';
import 'package:fuzzy_guacamole/styles/colors.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore mockFireStore;
  late DatabaseService dbService;

  const testUid = 'user_123';

  setUp(() {
    mockFireStore = FakeFirebaseFirestore();
    dbService = DatabaseService(fireStore: mockFireStore, uid: testUid);
  });

  group('Test database operations', () {
    test('Get all Meetings from specific User', () async {
      final ref = mockFireStore.collection(userCollectionRef).doc(testUid).collection(meetingCollectionRef);

      // Altes Persistenzformat (Datum als String): muss weiterhin lesbar sein.
      await ref.add({
        'eventName': 'eventName',
        'description': 'description',
        'start': DateTime(2025, 8, 21, 10, 30).toString(),
        'end': DateTime(2025, 8, 21, 11, 30).toString(),
        'labelColor': MyColors.lowLabel.toARGB32(),
        'priority': 'Low',
        'isAllDay': false,
      });

      await ref.add({
        'eventName': 'Test',
        'description': 'Hilfe',
        'start': DateTime(2025, 8, 23, 10, 30).toString(),
        'end': DateTime(2025, 8, 23, 11, 30).toString(),
        'labelColor': MyColors.lowLabel.toARGB32(),
        'priority': 'Low',
        'isAllDay': true,
      });

      final meetings = await dbService.meetingsStream.first;

      expect(meetings, hasLength(2));
      expect(meetings.map((m) => m.eventName), containsAll(['eventName', 'Test']));
    });

    test('Meetings from another user are not visible', () async {
      await mockFireStore.collection(userCollectionRef).doc('other_user').collection(meetingCollectionRef).add({
        'eventName': 'Fremdtermin',
        'description': '',
        'start': DateTime(2025, 8, 21, 10, 30).toString(),
        'end': DateTime(2025, 8, 21, 11, 30).toString(),
        'labelColor': MyColors.lowLabel.toARGB32(),
        'priority': 'Low',
        'isAllDay': false,
      });

      final meetings = await dbService.meetingsStream.first;
      expect(meetings, isEmpty);
    });

    test('Add a new Meeting', () async {
      final initialMeetings = await dbService.meetingsStream.first;
      expect(initialMeetings, isEmpty);

      final newMeeting = Meeting(
        eventName: 'New Meeting',
        description: 'New Meeting added',
        start: DateTime(2025, 8, 8, 11, 30),
        end: DateTime(2025, 8, 8, 13, 30),
        labelColor: MyColors.highLabel,
        priority: 'High',
        isAllDay: false,
      );

      await dbService.addMeeting(newMeeting);

      final updatedMeetings = await dbService.meetingsStream.first;

      expect(updatedMeetings, hasLength(1));
      expect(updatedMeetings.first.eventName, 'New Meeting');
      expect(updatedMeetings.first.start, DateTime(2025, 8, 8, 11, 30));
      expect(updatedMeetings.first.end, DateTime(2025, 8, 8, 13, 30));
    });

    test('Delete an existing Meeting', () async {
      final meeting = Meeting(
        eventName: 'New Meeting',
        description: 'New Meeting added',
        start: DateTime(2025, 8, 8, 11, 30),
        end: DateTime(2025, 8, 8, 13, 30),
        labelColor: MyColors.highLabel,
        priority: 'High',
        isAllDay: false,
      );

      await dbService.addMeeting(meeting);
      final [addedMeeting] = await dbService.meetingsStream.first;
      expect(addedMeeting.eventName, 'New Meeting');

      await dbService.deleteMeeting(addedMeeting.meetingId!);
      final updatedMeetings = await dbService.meetingsStream.first;
      expect(updatedMeetings, isEmpty);
    });

    test('Update an existing Meeting', () async {
      final originalMeeting = Meeting(
        eventName: 'New Meeting',
        description: 'New Meeting added',
        start: DateTime(2025, 8, 8, 11, 30),
        end: DateTime(2025, 8, 8, 13, 30),
        labelColor: MyColors.highLabel,
        priority: 'High',
        isAllDay: false,
      );

      await dbService.addMeeting(originalMeeting);
      final [addedMeeting] = await dbService.meetingsStream.first;

      final updatedMeeting = Meeting(
        eventName: 'Updated Meeting',
        description: 'Meeting updated',
        start: DateTime(2025, 8, 9, 12, 30),
        end: DateTime(2025, 8, 9, 15, 30),
        labelColor: MyColors.lowLabel,
        priority: 'Low',
        isAllDay: false,
      );

      await dbService.updateMeeting(addedMeeting.meetingId!, updatedMeeting);
      final [newMeeting] = await dbService.meetingsStream.first;
      expect(newMeeting.eventName, 'Updated Meeting');
      expect(newMeeting.description, 'Meeting updated');
      expect(newMeeting.priority, 'Low');
    });
  });
}
