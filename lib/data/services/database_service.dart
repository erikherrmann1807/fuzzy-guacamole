// lib/data/services/database_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzy_guacamole/constants.dart';
import 'package:fuzzy_guacamole/data/models/appointment_model.dart';
import 'package:fuzzy_guacamole/data/models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore db;
  final String uid;

  DatabaseService({FirebaseFirestore? fireStore, required this.uid})
      : db = fireStore ?? FirebaseFirestore.instance;

  CollectionReference<Meeting> get _meetingRef => db
      .collection(USER_COLLECTION_REF)
      .doc(uid)
      .collection(MEETING_COLLECTION_REF)
      .withConverter<Meeting>(
    fromFirestore: (snap, _) => Meeting.fromJson(snap.data()!, id: snap.id),
    toFirestore: (meet, _) => meet.toJson(),
  );

  CollectionReference<Member> get _userRef => db
      .collection(USER_COLLECTION_REF)
      .withConverter<Member>(
    fromFirestore: (snap, _) => Member.fromJson(snap.data()!),
    toFirestore: (user, _) => user.toJson(),
  );

  // --- Meetings ---
  Stream<List<Meeting>> get meetingsStream =>
      _meetingRef.snapshots().map((snap) => snap.docs.map((d) => d.data()).toList());

  Future<void> addMeeting(Meeting meeting) => _meetingRef.add(meeting);

  Future<void> deleteMeeting(String? meetingId) =>
      _meetingRef.doc(meetingId).delete();

  Future<void> updateMeeting(String? meetingId, Meeting meeting) =>
      _meetingRef.doc(meetingId).update(meeting.toJson());

  // --- Member / User ---
  Future<void> createMember(Member member) =>
      _userRef.doc(uid).set(member);

  Future<void> deleteMember() =>
      _userRef.doc(uid).delete();

  Future<void> updateMemberName(String userName) =>
      _userRef.doc(uid).update({'userName': userName});

  Future<Member?> getMember() async {
    final doc = await _userRef.doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<String?> getUsername() async {
    final m = await getMember();
    return m?.userName;
  }
}
