import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faceclient/screens/userdash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'alertDialog.dart';
import 'pwreset.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  @override
  _Login createState() => _Login();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
bool isLogginin = false;

class _Login extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;

  Future signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.shade200,
                Colors.redAccent,
              ],
            )),
          ),
          SingleChildScrollView(
            child: Center(
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 70),
                          child: Icon(
                            CupertinoIcons.camera_on_rectangle,
                            size: 250,
                            color: Colors.white,
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: 35, left: 30, right: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Email:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                        child: TextFormField(
                          controller: emailController,
                          style: TextStyle(
                              color: Colors.white, overflow: TextOverflow.fade),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(
                                  right: 5,
                                ),
                                child: Icon(
                                  CupertinoIcons.person_alt_circle_fill,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0,
                                ),
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              hintStyle: TextStyle(
                                  color: Colors.white,
                                  overflow: TextOverflow.fade),
                              hintText: "Enter your email",
                              fillColor: Colors.white12),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 35, left: 30, right: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Password:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(
                                  right: 5,
                                ),
                                child: Icon(
                                  CupertinoIcons.lock_circle_fill,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 0,
                                ),
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              hintStyle: TextStyle(color: Colors.white),
                              hintText: "Enter your password",
                              fillColor: Colors.white12),
                        ),
                      ),
                      Visibility(
                          visible: !isLogginin,
                          child: Padding(
                              padding: EdgeInsets.only(top: 35),
                              child: SizedBox(
                                  width: double.infinity,
                                  height: 45,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(right: 20, left: 20),
                                    child: ElevatedButton(
                                        child: Text('Login'),
                                        style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all<Color>(
                                                    Colors.red),
                                            backgroundColor:
                                                MaterialStateProperty.all<Color>(
                                                    Colors.white),
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(
                                                        30),
                                                    side: BorderSide(
                                                        color: Colors.white)))),
                                        onPressed: () async {
                                          setState(() {
                                            isLogginin = !isLogginin;
                                          });
                                          signIn(
                                                  email: emailController.text
                                                      .trim(),
                                                  password:
                                                      passwordController.text)
                                              .then((result) async {
                                            if (result == null) {
                                              var isAdmin =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection("Users")
                                                      .where("uid",
                                                          isEqualTo:
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  ?.uid)
                                                      .get();
                                              var adminornot =
                                                  isAdmin.docs[0]["isAdmin"];
                                              if (adminornot) {
                                                FirebaseAuth.instance.signOut();
                                                showAlertDialog(
                                                    context,
                                                    "Please Sign-in using a non-administrator acount",
                                                    "Login Error");
                                                setState(() {
                                                  isLogginin = !isLogginin;
                                                });
                                              } else {
                                                userName =
                                                    isAdmin.docs[0]["FullName"];
                                                photoUrl =
                                                    isAdmin.docs[0]["Photo"];
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                UserDashUI()));
                                              }
                                            } else {
                                              showAlertDialog(context, result,
                                                  "Login Error");
                                              setState(() {
                                                isLogginin = !isLogginin;
                                              });
                                            }
                                          });
                                        }),
                                  )))),
                      Visibility(
                        child: Padding(
                          child: CircularProgressIndicator(color: Colors.white),
                          padding: EdgeInsets.only(top: 15),
                        ),
                        visible: isLogginin,
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: Padding(
                                  padding: EdgeInsets.only(right: 65, left: 20),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                            child: Text('Forgot Password'),
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Pwreset()));
                                            }),
                                        SizedBox(
                                            height: 25,
                                            child: VerticalDivider(
                                              color: Colors.white,
                                              thickness: 2,
                                              indent: 0,
                                              endIndent: 0,
                                              width: 10,
                                            )),
                                        TextButton(
                                            child: Text('Sign-Up'),
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Signup()));
                                            }),
                                      ]))))
                    ],
                  ),
                ),
              ),
            ),
          )
        ]));
  }
}
