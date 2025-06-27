import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzy_guacamole/appointments/appointment_model.dart';

const String MEETING_COLLECTION_REF = "meetings";

class DatabaseService {
  final db = FirebaseFirestore.instance;
  late final CollectionReference meetingRef;
  StreamSubscription? _meetingSub;

  DatabaseService() {
    meetingRef = db
        .collection(MEETING_COLLECTION_REF)
        .withConverter<Meeting>(
          fromFirestore: (snapshots, _) => Meeting.fromJson(snapshots.data()!, id: snapshots.id),
          toFirestore: (meeting, _) => meeting.toJson(),
        );
  }

  void startListening(void Function(List<Meeting>) onData) {
    _meetingSub = meetingRef.snapshots().listen(
      (snap) {
        final meetings = snap.docs.map((d) => d.data() as Meeting).toList();
        onData(meetings);
      },
      onError: (e) {
        print('Firestore error: $e');
      },
    );
  }

  void stopListening() {
    _meetingSub?.cancel();
  }

  void addMeeting(Meeting meeting) async {
    meetingRef.add(meeting);
  }

  void deleteMeeting(String? meetingId) {
    meetingRef.doc(meetingId).delete();
  }

  void updateMeeting(String? meetingId, Meeting meeting) {
    meetingRef.doc(meetingId).update(meeting.toJson());
  }
}
