import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  bool _loginLoading = false;
  bool _obscureText = true;
  final controller = Get.put(LoginController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  read() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'uid';
    final value = prefs.get(key) ?? 0;
    if (value != 0) {
      _firestore
          .collection("users")
          .where("uID", isEqualTo: value)
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((s) async {
                  controller.loginWithEmail(s['email'], s['password']);
                  Get.offNamed(Routes.HOME);
                })
              });
    }
  }

  @override
  void initState() {
    read();
    controller.takeFCMTokenWhenAppLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "LOGIN",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: size.height * 0.03),
              SizedBox(height: size.height * 0.03),
              TextFieldContainer(
                child: TextField(
                  enabled: !_loginLoading,
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                    hintText: "E-mail",
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextFieldContainer(
                  child: Stack(
                children: <Widget>[
                  TextField(
                    enabled: !_loginLoading,
                    obscureText: _obscureText,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      icon: Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  )
                ],
              )),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: size.width * 0.8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: ElevatedButton(
                      onPressed: !_loginLoading
                          ? () {
                              controller.loginWithEmail(_emailController.text,
                                  _passwordController.text);
                            }
                          : () {},
                      style: ElevatedButton.styleFrom(
                        primary: !_loginLoading ? kPrimaryColor : Colors.grey,
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      ),
                      child: !_loginLoading
                          ? Text(
                              "LOGIN",
                              style: TextStyle(color: Colors.white),
                            )
                          : Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
