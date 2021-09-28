import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/firebase_api.dart';
import 'package:flutter_firebase_chat/scene.dart';
import 'package:flutter_firebase_chat/views/users.dart';
import 'package:flutter_firebase_chat/views/signup.dart';

class SigninView extends StatefulWidget {
  const SigninView({Key? key}) : super(key: key);

  @override
  _SigninViewState createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      if (Fapi.instance.isUser) {
        await Fapi.instance.LoadProfile();
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          Fapi.instance.FCMToken = token;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => UsersView(),
          ),
        );
      }
      // else {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute<void>(
      //       builder: (BuildContext context) => const SigninView(),
      //     ),
      //   );
      // }
    });
  }

  final _email = TextEditingController();
  final _password = TextEditingController();
  var loading = false;
  @override
  Widget build(BuildContext context) {
    return Scene(
      scroll: true,
      loading: loading,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const FlutterLogo(
              size: 100,
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Email",
                ),
                onChanged: (v) {
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _password,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Password",
                ),
                onChanged: (v) {
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    label: Text("signin".toUpperCase()),
                    onPressed: _email.text.isEmpty || _password.text.isEmpty
                        ? null
                        : () async {
                            setState(() {
                              loading = true;
                            });
                            RMessage _result = await Fapi.instance.signin(
                                email: _email.text, password: _password.text);
                            if (_result.done) {
                              await Fapi.instance.LoadProfile();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      UsersView(),
                                ),
                              );
                            } else {
                              setState(() {
                                loading = false;
                              });
                              for (var message in _result.messages) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message)));
                              }
                            }
                          },
                    icon: const Icon(Icons.login)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: const [
                  Expanded(
                    child: Divider(
                      height: 2,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  label: Text("Signup".toUpperCase()),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const SignupView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
