import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String name;
  final String photo;
  final String uid;
  final String? FCMToken;

  Profile({
    required this.name,
    required this.photo,
    required this.uid,
    this.FCMToken,
  });



  static find(String uid) async {
    var _docs = await FirebaseFirestore.instance.collection("profiles").where("uid",isEqualTo: uid).get();
    var _profileData = _docs.docs.first;
    return Profile.fromMap(_profileData.data());
  }

  Profile copyWith({
    String? name,
    String? photo,
    String? uid,
    String? FCMToken,
  }) {
    return Profile(
      name: name ?? this.name,
      photo: photo ?? this.photo,
      uid: uid ?? this.uid,
      FCMToken: FCMToken ?? this.FCMToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photo': photo,
      'uid': uid,
      'FCMToken': FCMToken,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      name: map['name'],
      photo: map['photo'],
      uid: map['uid'],
      FCMToken: map['FCMToken'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) => Profile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Profile(name: $name, photo: $photo, uid: $uid, FCMToken: $FCMToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Profile &&
      other.name == name &&
      other.photo == photo &&
      other.uid == uid &&
      other.FCMToken == FCMToken;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      photo.hashCode ^
      uid.hashCode ^
      FCMToken.hashCode;
  }
}
