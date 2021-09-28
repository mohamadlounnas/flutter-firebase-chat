import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/apis/notifications.dart';

import 'package:flutter_firebase_chat/models/profile.dart';
import 'package:flutter_firebase_chat/models/room.dart';
import 'package:flutter_firebase_chat/views/room.dart';
import 'package:http/http.dart';

class RMessage {
  bool done = false;
  List<String> messages = [];
  List<Function(BuildContext)> actions = [];
  RMessage({
    bool? done,
    List<String>? messages,
    List<Function(BuildContext)>? actions,
  }) {
    this.done = done ?? this.done;
    this.actions = actions ?? this.actions;
    this.messages = messages ?? this.messages;
  }
}

class Fapi {
  var showAttention = ValueNotifier(true);
  String? FCMPayload;
  String _FCMToken = "";

  String get FCMToken => _FCMToken;

  set FCMToken(String FCMToken) {
    _FCMToken = FCMToken;
    updateFCMToken();
  }

  updateFCMToken() async {
    try {
    var collection = await FirebaseFirestore.instance
        .collection("profiles")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"FCMToken": FCMToken});
    } catch (e) {
      // i dont expect that
    }
  }

  Fapi._();
  static Fapi instance = Fapi._();
  updateProfile({required Profile profile}) {
    FirebaseFirestore.instance
        .collection("profiles")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(profile.toMap());
    this.profile = profile;
  }

  static const FIREBASE_SERVER_KEY =
      "AAAAvjOKsVY:APA91bHsWIfHJ54LrLQjnOM3x8gFCHnyakxxMqOylkLQTKs5z02e-PBLRlNU1QzYvRJcaBD1VG2Jfh1kAIc9PKc3mjg30Sznk1UjLS7e3VMd9SwaM6fMSSx5qUhoI_500ZHOQCnn_jSv";
  Notifications notifications = Notifications();

  Profile? profile;
  LoadProfile() async {
    if (Fapi.instance.profile == null) {
      var _profile = await FirebaseFirestore.instance
          .collection("profiles")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      profile = Profile.fromMap(_profile.data() as Map<String, dynamic>);

      if (profile!.FCMToken == "") {
        var _fcmToken = await FirebaseMessaging.instance.getToken();
        FirebaseFirestore.instance
            .collection("profiles")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({"FCMToken": _fcmToken});
        profile = profile!.copyWith(FCMToken: _fcmToken);
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      Fapi.instance.FCMToken = token;
    });
  }

  Future<RMessage> signup(
      {required String name,
      required String email,
      required String password,
      String photo = "https://picsum.photos/300/300"}) async {
    var rMessage = RMessage();
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((user) async {
        var _fcmToken = await FirebaseMessaging.instance.getToken();
        updateProfile(
            profile: Profile(
                uid: user.user!.uid,
                name: name,
                photo: photo,
                FCMToken: _fcmToken ?? ""));
        return user;
      });
      rMessage.done = true;
    } on FirebaseAuthException catch (e) {
      rMessage.messages.add(e.code.replaceAll("-", " "));
    } catch (e) {
      rMessage.messages.add('$e');
    }
    return rMessage;
  }

  Future<RMessage> signout() async {
    var rMessage = RMessage();
    try {
      Fapi.instance.FCMToken = "";
      await FirebaseAuth.instance.signOut();
      rMessage.done = true;
    } catch (e) {
      rMessage.done = false;
      rMessage.messages.add('$e');
    }
    return rMessage;
  }

  bool get isUser {
    return FirebaseAuth.instance.currentUser == null ? false : true;
  }

  Future<RMessage> signin(
      {required String email, required String password}) async {
    var rMessage = RMessage();
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      rMessage.done = true;
    } on FirebaseAuthException catch (e) {
      rMessage.done = false;
      rMessage.messages.add(e.code.replaceAll("-", " "));
    } catch (e) {
      rMessage.done = false;
      rMessage.messages.add('$e');
    }
    return rMessage;
  }
}

class Nav {
  static void openRoom(BuildContext context,
      {required Profile profile, required Room room}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => RoomView(
          profile: profile,
          room: room,
        ),
      ),
    );
  }
}
