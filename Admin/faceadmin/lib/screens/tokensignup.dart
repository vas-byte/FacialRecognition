import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'AlertDialogs.dart';

class TokenSignup extends StatelessWidget {
  final TextEditingController email = TextEditingController();

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  String token = "";

  @override
  Widget build(BuildContext context) {
    token = getRandomString(7);
    return Scaffold(
      bottomSheet: BottomSheet(
          onClosing: () {},
          builder: (context) => Container(
                width: double.maxFinite,
                height: (() {
                  if (Platform.isAndroid) {
                    return 70.0;
                  } else if (Platform.isIOS) {
                    return 90.0;
                  }
                }()),
                padding: EdgeInsets.only(
                    bottom: (() {
                      if (Platform.isAndroid) {
                        return 20.0;
                      }

                      return 40.0;
                    }()),
                    left: 10,
                    right: 10),
                child: ElevatedButton(
                    child: Text("Add User"),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: Colors.red)))),
                    onPressed: () {
                      print(email.text);
                      if (validateEmail(email.text)) {
                        FirebaseFirestore.instance.collection('mail').add({
                          'to': email.text.trim(),
                          'template': {
                            'name': 'token',
                            'data': {
                              'tokencode': token,
                            }
                          },
                        });
                        FirebaseFirestore.instance
                            .collection("Tokens")
                            .doc()
                            .set({"id": token});
                        Navigator.of(context).pop();
                      } else {
                        print("else");
                        showAlertDialog(context, "Email Adress");
                      }
                    }),
              )),
      appBar: AppBar(title: Text("Add user"), backgroundColor: Colors.red),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Container(
                width: 350,
                height: 150,
                padding: EdgeInsets.only(top: 35),
                child: Card(
                    elevation: 5,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "One Time Code:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 30),
                            ),
                            Text(
                              token,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 30),
                            )
                          ]),
                    ))),
            Padding(
                padding: EdgeInsets.only(top: 50, right: 20, left: 20),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Email:',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ))),
            Padding(
                padding: EdgeInsets.only(top: 0, right: 20, left: 20),
                child: TextFormField(
                    controller: email,
                    decoration: new InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                    ))),
          ],
        ))),
      ),
    );
  }
}

bool validateEmail(String value) {
  String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  RegExp regex = RegExp(pattern);
  if (value == null || value.isEmpty || !regex.hasMatch(value))
    return false;
  else
    return true;
}
