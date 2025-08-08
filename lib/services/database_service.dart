import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzy_guacamole/models/appointment_model.dart';
import 'package:fuzzy_guacamole/models/user_model.dart';
import 'package:fuzzy_guacamole/constants/database_refs.dart';

import 'auth_service.dart';

class DatabaseService {
  final FirebaseFirestore db;
  final AuthService auth;
  late final CollectionReference<Meeting> meetingRef;
  late final CollectionReference<Member>   userRef;

  DatabaseService({FirebaseFirestore? fireStore, AuthService? authService})
      : db   = fireStore ?? FirebaseFirestore.instance,
        auth = authService ?? authServiceGlobal.value {

    final uid = auth.currentUser?.uid;
    meetingRef = db
        .collection(USER_COLLECTION_REF)
        .doc(uid)
        .collection(MEETING_COLLECTION_REF)
        .withConverter<Meeting>(
      fromFirestore: (snap, _) => Meeting.fromJson(snap.data()!, id: snap.id),
      toFirestore:   (meet, _) => meet.toJson(),
    );

    userRef = db
        .collection(USER_COLLECTION_REF)
        .withConverter<Member>(
      fromFirestore: (snap, _) => Member.fromJson(snap.data()!),
      toFirestore:   (user, _) => user.toJson(),
    );
  }

  // void startListening(void Function(List<Meeting>) onData) {
  //   _meetingSub = meetingRef.snapshots().listen(
  //     (snap) {
  //       final meetings = snap.docs.map((d) => d.data() as Meeting).toList();
  //       onData(meetings);
  //     },
  //     onError: (e) {
  //       print('Firestore error: $e');
  //     },
  //   );
  // }

  Stream<List<Meeting>> get meetingsStream {
    return meetingRef.snapshots().map((snap) {
      return snap.docs
          .map((d) => d.data())
          .toList();
    });
  }

  // void stopListening() {
  //   _meetingSub?.cancel();
  // }

  Future<void> addMeeting(Meeting meeting) async {
    await meetingRef.add(meeting);
  }

  Future<void> deleteMeeting(String? meetingId) async {
    await meetingRef.doc(meetingId).delete();
  }

  Future<void> updateMeeting(String? meetingId, Meeting meeting) async {
    await meetingRef.doc(meetingId).update(meeting.toJson());
  }

  void createMember(Member member) async {
    userRef.doc(authServiceGlobal.value.currentUser!.uid).set(member);
  }

  void deleteMember() {
    userRef.doc(authServiceGlobal.value.currentUser!.uid).delete();
  }

  void updateMemberName(String userName) async {
    userRef.doc(authServiceGlobal.value.currentUser!.uid).update({'userName': userName});
  }

  Future<String> getUsername() async {
    final uid = authServiceGlobal.value.currentUser!.uid;
    final doc = await userRef
        .doc(uid)
        .get();
    final member = doc.data()!;
    return member.userName;
  }

}
