import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/firebase_api.dart';
import 'package:flutter_firebase_chat/main.dart';
import 'package:flutter_firebase_chat/models/message.dart';
import 'package:flutter_firebase_chat/models/profile.dart';
import 'package:flutter_firebase_chat/models/room.dart';
import 'package:flutter_firebase_chat/views/signin.dart';

class UsersView extends StatelessWidget {
  UsersView({Key? key}) : super(key: key);
  var searchQueryTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(Fapi.instance.profile!.photo),
              ),
              if (Fapi.instance.profile!.FCMToken != "")
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
            Fapi.instance.profile!.name.toUpperCase(),
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            Fapi.instance.profile!.FCMToken != ""
                ? "Connected"
                : "Disconnected",
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await Fapi.instance.signout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const SigninView(),
                  ),
                  ModalRoute.withName('/'),
                );
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("profiles").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            var seenValue = false;
            return ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100)),
                  margin: const EdgeInsets.all(12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: searchQueryTextController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search_sharp),
                      hintText: "Search here",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: Fapi.instance.showAttention,
                  builder: (context, bool showAttentionValue, snapshot) {
                    return !showAttentionValue
                        ? const SizedBox()
                        : Container(
                            color: Colors.amber.withOpacity(0.3),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 24),
                                  child: Icon(
                                    Icons.report_problem,
                                    color: Colors.amber,
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    child: Text(
                                      "This app is only for development propose, we do not recommended to use in personel or commercail cases.\ndeveloped by: @mohamadlounnas",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText2!
                                            .color!
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      Fapi.instance.showAttention.value = false;
                                    },
                                    icon: const Icon(Icons.close))
                              ],
                            ),
                          );
                  },
                ),
                ...snapshot.data!.docs.map((DocumentSnapshot document) {
                  Profile profile =
                      Profile.fromMap(document.data() as Map<String, dynamic>);
                  var _roomUids = ([
                    profile.uid,
                    FirebaseAuth.instance.currentUser!.uid
                  ]..sort());
                  String _roomId = _roomUids.join('_');
                  var room = Room(id: _roomId, uids: _roomUids);
                  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection("rooms")
                          .doc(room.id)
                          .snapshots(),
                      builder: (context2, snapshot2) {
                        try {
                          var _data = snapshot2.data!.data()!;
                          var _seen = _data["seen"] ?? false;
                          seenValue = _seen;
                        } catch (e) {}

                        return ListTile(
                          tileColor: !seenValue
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.transparent,
                          onTap: () async {
                            var data = await FirebaseFirestore.instance
                                .collection('rooms')
                                .doc(room.id)
                                .set({"uids": room.uids, "seen": true});
                            Nav.openRoom(context, profile: profile, room: room);
                          },
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(profile.photo),
                              ),
                              if (profile.FCMToken != "")
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 2, color: Colors.white)),
                                  ),
                                )
                            ],
                          ),
                          title: Text(
                            profile.name,
                            style: TextStyle(
                                fontWeight: seenValue
                                    ? FontWeight.normal
                                    : FontWeight.bold),
                          ),
                          subtitle: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("messages")
                                .where("room", isEqualTo: room.id)
                                .orderBy('created', descending: true)
                                .limitToLast(1)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                if (snapshot.data!.docs.isEmpty) {
                                  return const Text("Send 👋👋");
                                }
                                Message message = Message.fromMap(
                                    snapshot.data!.docs.first.data()
                                        as Map<String, dynamic>);

                                return Text(
                                  message.content,
                                  style: TextStyle(
                                      fontWeight: seenValue
                                          ? FontWeight.normal
                                          : FontWeight.bold),
                                );
                              }
                              return const LinearProgressIndicator();
                            },
                          ),
                        );
                      });
                }).toList()
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
