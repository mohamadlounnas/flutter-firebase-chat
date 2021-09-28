import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content;
  final String type;
  final String uid;
  final String room;
  final dynamic created;

  Message({
    required this.content,
    required this.type,
    required this.uid,
    required this.room,
    required this.created,
  });



  Message copyWith({
    String? content,
    String? type,
    String? uid,
    String? room,
    dynamic? created,
  }) {
    return Message(
      content: content ?? this.content,
      type: type ?? this.type,
      uid: uid ?? this.uid,
      room: room ?? this.room,
      created: created ?? this.created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'type': type,
      'uid': uid,
      'room': room,
      'created': created,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      content: map['content'],
      type: map['type'],
      uid: map['uid'],
      room: map['room'],
      created: map['created'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Message(content: $content, type: $type, uid: $uid, room: $room, created: $created)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Message &&
      other.content == content &&
      other.type == type &&
      other.uid == uid &&
      other.room == room &&
      other.created == created;
  }

  @override
  int get hashCode {
    return content.hashCode ^
      type.hashCode ^
      uid.hashCode ^
      room.hashCode ^
      created.hashCode;
  }
}
