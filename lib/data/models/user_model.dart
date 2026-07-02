import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Nutzerprofil-Dokument in der `users`-Collection.
@immutable
class Member {
  final String userName;
  final String email;
  final Timestamp? createdAt;

  const Member({required this.userName, required this.email, this.createdAt});

  Member copyWith({String? userName, String? email, Timestamp? createdAt}) {
    return Member(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// `createdAt` wird nur beim ersten Schreiben serverseitig gesetzt und
  /// danach nicht mehr überschrieben.
  Map<String, dynamic> toJson() => {
    'userName': userName,
    'email': email,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };

  factory Member.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    return Member(
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt : null,
    );
  }
}
