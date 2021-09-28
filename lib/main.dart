import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_chat/firebase_api.dart';
import 'package:flutter_firebase_chat/models/profile.dart';
import 'package:flutter_firebase_chat/models/room.dart';
import 'package:flutter_firebase_chat/views/room.dart';
import 'package:flutter_firebase_chat/views/users.dart';
import 'package:flutter_firebase_chat/views/signin.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(RootWidget());
}

class RootWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter firebase chat',
      
      theme: ThemeData(
      appBarTheme: AppBarTheme(
        textTheme: Theme.of(context).textTheme,
        backgroundColor: Theme.of(context).cardColor,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1!.color),
      ),
        primarySwatch: Colors.blue,
      ),
      home: const MainView(),
    );
  }
}

///
class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

  Future<void> _FCMBackgroundHandler(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        android.channelId ?? "channelId",
        'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        color: Colors.yellow,
        priority: Priority.high,
        ticker: 'ticker',
      );
      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0, notification.title, notification.body, platformChannelSpecifics,
          payload: jsonEncode(message.data));
    }
  }  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class _MainViewState extends State<MainView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _initApp();
    });
  }

  onSelectNotification(payload) async {
    debugPrint('notification payload: $payload');
    if (payload != null) {
      Fapi.instance.FCMPayload = payload;
      var data = jsonDecode(payload);

      var profile = await Profile.find(data["from_uid"]);
      var _roomUids = <String>[
        data["from_uid"],
        FirebaseAuth.instance.currentUser!.uid
      ]..sort();
      String _roomId = _roomUids.join('_');
      var room = Room(id: _roomId, uids: _roomUids);

      await Navigator.push<void>(
        navigatorKey.currentState!.context,
        MaterialPageRoute<void>(
          builder: (BuildContext ctx) => RoomView(room: room, profile: profile),
        ),
      );
      //  await Navigator.pushAndRemoveUntil<void>(
      //   navigatorKey.currentState!.context,
      //   MaterialPageRoute<void>(
      //       builder: (BuildContext ctx) =>
      //           RoomView.fromUid(data["from_uid"])),
      //   ModalRoute.withName('/'),
      // );
    }
  }


  void _initApp() async {
     FirebaseMessaging.onMessage.listen(_FCMBackgroundHandler);
     FirebaseMessaging.onMessageOpenedApp.listen(_FCMBackgroundHandler);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
     FirebaseMessaging.onBackgroundMessage(_FCMBackgroundHandler);

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    var details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details!.didNotificationLaunchApp) {
      onSelectNotification(details.payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SigninView();
  }
}
