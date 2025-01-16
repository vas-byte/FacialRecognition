import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'alertDialog.dart';
import 'login.dart';

class Pwreset extends StatefulWidget {
  @override
  _Pwreset createState() => _Pwreset();
}

class _Pwreset extends State<Pwreset> {
  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
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
                child: Column(children: [
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
                  controller: email,
                  style: TextStyle(color: Colors.white),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          right: 5,
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_2_circlepath,
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
                      hintText: "Enter your email",
                      fillColor: Colors.white12),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(top: 15, right: 20, left: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                        child: Text('Reset Password'),
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: Colors.white)))),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email.text);
                            showAlertDialog(context, "Reset Email Sent",
                                "Please check your inbox");
                          } catch (e) {
                            showAlertDialog(context, e.toString(), "Error");
                          }
                        }),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20, left: 20),
                        child: TextButton(
                            child: Text('Back To Login'),
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop(MaterialPageRoute(
                                  builder: (context) => Login()));
                            }),
                      )))
            ]))
          ],
        ));
  }
}
