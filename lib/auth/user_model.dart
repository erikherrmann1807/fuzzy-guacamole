import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  String userName;
  String email;
  String? createdAt;

  Member({
    required this.userName,
    required this.email,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'email' : email,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
        userName: json['userName'] as String,
        email: json['email'] as String,
        createdAt: json['createdAt'] as String,
    );
  }
}