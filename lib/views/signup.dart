import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/firebase_api.dart';
import 'package:flutter_firebase_chat/main.dart';
import 'package:flutter_firebase_chat/scene.dart';
import 'package:flutter_firebase_chat/views/users.dart';
import 'package:flutter_firebase_chat/views/signin.dart';

class SignupView extends StatefulWidget {
  const SignupView({Key? key}) : super(key: key);

  @override
  _SignupViewState createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var loading = false;
  @override
  Widget build(BuildContext context) {
    return Scene(
                    scroll:true,
      loading: loading,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                controller: _name,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Name",
                ),
                onChanged: (v) {
                  setState(() {});
                },
              ),
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
                  label: Text("signup".toUpperCase()),
                  onPressed: _email.text.isEmpty || _password.text.isEmpty
                      ? null
                      : () async {
                        var __name = _name.text;
                        var __email = _email.text;
                        var __password = _password.text;
                          setState(() {
                            loading = true;
                          });
                          RMessage _result = await Fapi.instance
                              .signup(name:__name,email:__email,password:__password,photo: "https://picsum.photos/300/300?"+UniqueKey().toString());
                          
                          if (_result.done) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) =>  UsersView(),
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
                  icon: const Icon(Icons.person_add_alt),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: const [
                  Expanded(
                    child:  Divider(
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
                  label: Text("Signin".toUpperCase()),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => SigninView(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
