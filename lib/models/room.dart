import 'dart:convert';

import 'package:flutter/foundation.dart';

class Room {
  final String id;
  final bool seen;
  final List<String> uids;
  Room({
    required this.id,
    this.seen = false,
    required this.uids,
  });


  Room copyWith({
    String? id,
    bool? seen,
    List<String>? uids,
  }) {
    return Room(
      id: id ?? this.id,
      seen: seen ?? this.seen,
      uids: uids ?? this.uids,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seen': seen,
      'uids': uids,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      seen: map['seen'],
      uids: List<String>.from(map['uids']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Room.fromJson(String source) => Room.fromMap(json.decode(source));

  @override
  String toString() => 'Room(id: $id, seen: $seen, uids: $uids)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Room &&
      other.id == id &&
      other.seen == seen &&
      listEquals(other.uids, uids);
  }

  @override
  int get hashCode => id.hashCode ^ seen.hashCode ^ uids.hashCode;
}
