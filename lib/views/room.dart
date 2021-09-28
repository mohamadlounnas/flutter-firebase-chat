import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/apis/notifications.dart';
import 'package:flutter_firebase_chat/firebase_api.dart';
import 'package:flutter_firebase_chat/models/message.dart';
import 'package:flutter_firebase_chat/models/profile.dart';
import 'package:flutter_firebase_chat/models/room.dart';
import 'package:flutter_firebase_chat/scene.dart';
import 'package:flutter_firebase_chat/views/users.dart';
import 'package:http/http.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;

class RoomView extends StatelessWidget {
  final Profile profile;
  final Room room;

  RoomView({Key? key, required this.room, required this.profile})
      : super(key: key);

  final _message = TextEditingController();
  final _focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil<void>(
              MaterialPageRoute<void>(
                  builder: (BuildContext context) => UsersView()),
              ModalRoute.withName('/'),
            );
          },
        ),
        titleSpacing: -20,
        title: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(profile.photo),
              ),
              if (profile.FCMToken != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(width: 2, color: Colors.white)),
                  ),
                )
            ],
          ),
          title: Text(
            profile.name.toUpperCase(),
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            profile.FCMToken != null ? "Connected" : "Disconnected",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .where("room", isEqualTo: room.id)
                  .orderBy('created', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Scene(
                    child: ListView(
                      reverse: true,
                      children: [
                        const SizedBox(
                          height: 70,
                        ),
                        ...snapshot.data!.docs.map((DocumentSnapshot document) {
                          Message message = Message.fromMap(
                              document.data() as Map<String, dynamic>);
                          Widget _widget;
                          _widget = message.uid == profile.uid
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(profile.photo),
                                      ),
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(
                                          minHeight: 35, minWidth: 35),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.grey.withOpacity(0.4),
                                      ),
                                      margin: EdgeInsets.only(left: 12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Center(
                                        child: Text(
                                          message.content,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                          minHeight: 35, minWidth: 35),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.blue,
                                      ),
                                      margin: const EdgeInsets.only(left: 12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Center(
                                        child: Text(
                                          message.content,
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 3),
                            child: _widget,
                          );
                        }).toList()
                      ],
                    ),
                  );
                }
                return const Center(
                  child: Text("No data"),
                );
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Card(
              child: Row(
                children: [
                  const IconButton(
                    onPressed: null,
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                  Flexible(
                    child: TextField(
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Hint Text',
                        border: InputBorder.none,
                      ),
                      controller: _message,
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _sendMessage(_message.text);
                    },
                    icon: const Icon(Icons.send_outlined),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    _message.clear();
    _focusNode.requestFocus();
    var tt = FieldValue.serverTimestamp();
    Message message = Message(
        content: text,
        type: "text",
        room: room.id,
        uid: FirebaseAuth.instance.currentUser!.uid,
        created: FieldValue.serverTimestamp());
    // FirebaseFirestore.instance.collection('messages').doc(widget.room.id+"_"+DateTime.now()).set({"uids":room.uids});

    FirebaseFirestore.instance
        .collection("messages")
        .add(message.toMap())
        .then((value) {
      print(value);
    });
    // Fapi.instance.sendNotificationTo(profile.uid);
    if (profile.FCMToken != null) {
      Fapi.instance.notifications.send(NotificationMessage(to: profile.FCMToken!, title: Fapi.instance.profile!.name,body: text));
    }
  }

  static fromUid(String uid) async {
    var profile = await Profile.find(uid);
    var _roomUids = [uid, FirebaseAuth.instance.currentUser!.uid]..sort();
    String _roomId = _roomUids.join('_');
    var room = Room(id: _roomId, uids: _roomUids);
    return RoomView(room: room, profile: profile);
  }
}
