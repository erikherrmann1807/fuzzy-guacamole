import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzy_guacamole/appointments/appointment_model.dart';
import 'package:fuzzy_guacamole/auth/user_model.dart';
import 'package:fuzzy_guacamole/constants/database_refs.dart';

import 'auth_service.dart';

class DatabaseService {
  final db = FirebaseFirestore.instance;
  late final CollectionReference meetingRef;
  late final CollectionReference userRef;
  StreamSubscription? _meetingSub;

  DatabaseService() {
    meetingRef = db.collection(USER_COLLECTION_REF)
        .doc(authService.value.currentUser?.uid)
        .collection(MEETING_COLLECTION_REF)
        .withConverter<Meeting>(
          fromFirestore: (snapshots, _) => Meeting.fromJson(snapshots.data()!, id: snapshots.id),
          toFirestore: (meeting, _) => meeting.toJson(),
        );
    
    userRef = db.collection(USER_COLLECTION_REF)
    .withConverter<Member>(
        fromFirestore: (snapshots, _) => Member.fromJson(snapshots.data()!),
        toFirestore: (user, _) => user.toJson());
  }

  void startListening(void Function(List<Meeting>) onData) {
    _meetingSub = meetingRef.snapshots().listen(
      (snap) {
        final meetings = snap.docs
            .map((d) => d.data() as Meeting)
            .toList();
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

  void createMember(Member member) async {
    userRef.doc(authService.value.currentUser!.uid).set(member);
  }
  
  Future<String> getUsername() async {
    final documents = await userRef.where('email', isEqualTo: authService.value.currentUser?.email).get();
    final member = documents.docs.first.data() as Member;
    return member.userName;
  }
}
