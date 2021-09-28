import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

import 'package:flutter_firebase_chat/firebase_api.dart';

class NotificationMessage {
  final String to;
  final String title;
  final String body;
  NotificationMessage({
    required this.to,
    required this.title,
    required this.body,
  });

  NotificationMessage copyWith({
    String? to,
    String? title,
    String? body,
  }) {
    return NotificationMessage(
      to: to ?? this.to,
      title: title ?? this.title,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'to': to,
      'title': title,
      'body': body,
    };
  }

  factory NotificationMessage.fromMap(Map<String, dynamic> map) {
    return NotificationMessage(
      to: map['to'],
      title: map['title'],
      body: map['body'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationMessage.fromJson(String source) => NotificationMessage.fromMap(json.decode(source));

  @override
  String toString() => 'NotificationMessage(to: $to, title: $title, body: $body)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is NotificationMessage &&
      other.to == to &&
      other.title == title &&
      other.body == body;
  }

  @override
  int get hashCode => to.hashCode ^ title.hashCode ^ body.hashCode;
}
class Notifications {
    Future<Response> send(NotificationMessage message) async {
    var resp =  await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Fapi.FIREBASE_SERVER_KEY}',
      },
      body: jsonEncode(
        <String, dynamic>{
          "to": message.to,
          'priority': 'high',
          "notification": {
            "title": message.title,
            "body": message.body,
            "mutable_content": true,
            "sound": "Tri-tone"
          },
          "data": <String, dynamic>{
            'from_uid': FirebaseAuth.instance.currentUser!.uid,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          }
        },
      ),
    );

    return resp;
  }
}