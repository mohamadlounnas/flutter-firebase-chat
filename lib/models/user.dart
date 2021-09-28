import 'dart:convert';

import 'package:flutter_firebase_chat/models/profile.dart';

class User {
  final String email;
  final String password;
  final Profile profile;

  User({
    required this.email,
    required this.password,
    required this.profile,
  });


  User copyWith({
    String? email,
    String? password,
    Profile? profile,
  }) {
    return User(
      email: email ?? this.email,
      password: password ?? this.password,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'profile': profile.toMap(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'],
      password: map['password'],
      profile: Profile.fromMap(map['profile']),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() => 'User(email: $email, password: $password, profile: $profile)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      other.email == email &&
      other.password == password &&
      other.profile == profile;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode ^ profile.hashCode;
}
