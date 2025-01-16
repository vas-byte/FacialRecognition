import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faceclient/screens/userdash.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'alertDialog.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Signup extends StatefulWidget {
  @override
  _Signup createState() => _Signup();
}

TextEditingController fullNameSignup = TextEditingController();
TextEditingController emailAdress = TextEditingController();
TextEditingController pwd = TextEditingController();
TextEditingController confirmpwd = TextEditingController();
TextEditingController signupToken = TextEditingController();
late List<CameraDescription> camera;
late String identifier;

class _Signup extends State<Signup> {
  bool isTokenLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          Container(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                Padding(
                    padding: EdgeInsets.only(top: 55),
                    child: Icon(
                      CupertinoIcons.camera_on_rectangle,
                      size: 250,
                      color: Colors.white,
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 25, left: 30, right: 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sign-Up Token:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                  child: TextFormField(
                    controller: signupToken,
                    style: TextStyle(color: Colors.white),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            right: 5,
                          ),
                          child: Icon(
                            CupertinoIcons.money_rubl_circle_fill,
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
                        hintText: "Please enter your Sign-Up Token",
                        fillColor: Colors.white12),
                  ),
                ),
              ]))),
          Visibility(
              visible: !isTokenLoading,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 40,
                          child: ElevatedButton(
                              child: Text('Next'),
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
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          side: BorderSide(
                                              color: Colors.white)))),
                              onPressed: () async {
                                setState(() {
                                  isTokenLoading = !isTokenLoading;
                                });

                                final DeviceInfoPlugin deviceInfoPlugin =
                                    new DeviceInfoPlugin();
                                try {
                                  if (identifier == null ||
                                      identifier.isEmpty) {
                                    if (Platform.isAndroid) {
                                      var build =
                                          await deviceInfoPlugin.androidInfo;

                                      identifier = build.id;
                                    } else if (Platform.isIOS) {
                                      var data = await deviceInfoPlugin.iosInfo;

                                      identifier = data.identifierForVendor!;
                                    }
                                  }

                                  print(identifier);

                                  HttpsCallable callable = FirebaseFunctions
                                      .instance
                                      .httpsCallable('validateToken');

                                  try {
                                    final resp = await callable
                                        .call(<String, String>{
                                      'token': signupToken.text.trim(),
                                      'devid': identifier
                                    });
                                    print(resp.data);
                                    if (resp.data == "Valid Token") {
                                      Navigator.of(context).pushReplacement(
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  SignupDetails()));
                                    } else {
                                      setState(() {
                                        isTokenLoading = !isTokenLoading;
                                      });
                                      showAlertDialog(context,
                                          resp.data.toString(), "Error");
                                    }
                                  } on FirebaseFunctionsException catch (e) {
                                    print(e.toString());
                                  } catch (e) {
                                    print(e.toString());
                                  }
                                } on PlatformException {
                                  showAlertDialog(context,
                                      "Unable to get Device ID", "Error");
                                }
                              }),
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: TextButton(
                                onPressed: () async {
                                  signupToken.clear();
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Back To Login",
                                  style: TextStyle(color: Colors.white),
                                ))),
                      ]))),
          Visibility(
              visible: isTokenLoading,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ))))
        ],
      ),
    );
  }
}

class SignupDetails extends StatefulWidget {
  @override
  _SignupDetails createState() => _SignupDetails();
}

class _SignupDetails extends State<SignupDetails> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade200,
              Colors.redAccent,
            ],
          )),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                    Padding(
                        padding: EdgeInsets.only(top: 55),
                        child: Icon(
                          CupertinoIcons.camera_on_rectangle,
                          size: 250,
                          color: Colors.white,
                        )),
                    Padding(
                      padding: EdgeInsets.only(top: 25, left: 30, right: 0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Full Name:",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: TextFormField(
                        controller: fullNameSignup,
                        style: TextStyle(color: Colors.white),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Icon(
                                CupertinoIcons.person_alt_circle,
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
                            hintText: "Please enter your Name",
                            fillColor: Colors.white12),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25, left: 30, right: 0),
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
                        controller: emailAdress,
                        style: TextStyle(color: Colors.white),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Icon(
                                CupertinoIcons.envelope_circle_fill,
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
                            hintText: "Please enter your Email",
                            fillColor: Colors.white12),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 165),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 300,
                                height: 40,
                                child: ElevatedButton(
                                    child: Text('Next'),
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
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                side: BorderSide(
                                                    color: Colors.white)))),
                                    onPressed: () async {
                                      if (validateEmail(
                                                  emailAdress.text.trim()) ==
                                              false ||
                                          fullNameSignup.text == "") {
                                        if (fullNameSignup.text == "") {
                                          showAlertDialog(context,
                                              "Please Enter a Name", "Error");
                                        }

                                        if (validateEmail(
                                                emailAdress.text.trim()) ==
                                            false) {
                                          showAlertDialog(
                                              context,
                                              "Please Enter a Valid Email",
                                              "Error");
                                        }
                                      } else {
                                        Navigator.of(context).pushReplacement(
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    PasswordCreate()));
                                      }
                                    }),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: TextButton(
                                      onPressed: () async {
                                        signupToken.clear();
                                        fullNameSignup.clear();
                                        emailAdress.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Back To Login",
                                        style: TextStyle(color: Colors.white),
                                      ))),
                            ])),
                  ])),
            ),
          ),
        ));
  }
}

class PasswordCreate extends StatefulWidget {
  @override
  _PasswordCreate createState() => _PasswordCreate();
}

class _PasswordCreate extends State<PasswordCreate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade200,
              Colors.redAccent,
            ],
          )),
          child: SingleChildScrollView(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                Padding(
                    padding: EdgeInsets.only(top: 55),
                    child: Icon(
                      CupertinoIcons.camera_on_rectangle,
                      size: 250,
                      color: Colors.white,
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 25, left: 30, right: 0),
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
                    obscureText: true,
                    controller: pwd,
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
                        hintText: "Please enter a Password",
                        fillColor: Colors.white12),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25, left: 30, right: 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Confirm Password:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                  child: TextFormField(
                    obscureText: true,
                    controller: confirmpwd,
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
                        hintText: "Please re-type your password",
                        fillColor: Colors.white12),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 165),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 300,
                            height: 40,
                            child: ElevatedButton(
                                child: Text('Next'),
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
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            side: BorderSide(
                                                color: Colors.white)))),
                                onPressed: () async {
                                  if (pwd.text.isEmpty ||
                                      confirmpwd.text.isEmpty) {
                                    if (pwd.text.isEmpty) {
                                      showAlertDialog(context,
                                          "Please Create A Password", "Error");
                                    }
                                    if (confirmpwd.text.isEmpty) {
                                      showAlertDialog(
                                          context,
                                          "Please Confrim Your Password",
                                          "Error");
                                    }
                                  } else {
                                    if (pwd.text == confirmpwd.text &&
                                        pwd.text.length > 5) {
                                      camera = await availableCameras();
                                      Navigator.of(context).pushReplacement(
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  GetPhoto()));
                                    } else if (pwd.text != confirmpwd.text) {
                                      showAlertDialog(
                                          context,
                                          "The Passwords Do Not Match",
                                          "Error");
                                    } else if (pwd.text.length < 5) {
                                      showAlertDialog(
                                          context, "Weak Password", "Error");
                                    }
                                  }
                                }),
                          ),
                          Padding(
                              padding: EdgeInsets.only(bottom: 10),
                              child: TextButton(
                                  onPressed: () async {
                                    signupToken.clear();
                                    fullNameSignup.clear();
                                    emailAdress.clear();
                                    pwd.clear();
                                    confirmpwd.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Back To Login",
                                    style: TextStyle(color: Colors.white),
                                  ))),
                        ])),
              ])))),
    );
  }
}

class GetPhoto extends StatefulWidget {
  @override
  _GetPhoto createState() => _GetPhoto();
}

class _GetPhoto extends State<GetPhoto> {
  bool imageTaken = false;
  File imagePath = File('');
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller =
        CameraController(camera.last, ResolutionPreset.max, enableAudio: false);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          Container(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                Visibility(
                    visible: !imageTaken,
                    child: Padding(
                        padding: EdgeInsets.only(top: 55),
                        child: SizedBox(
                            width: 300,
                            child: Stack(children: [
                              CustomPaint(
                                foregroundPainter: P(),
                                child: CameraPreview(controller),
                              ),
                              ClipPath(
                                  clipper: Clip(),
                                  child: CameraPreview(controller)),
                            ])))),
                Visibility(
                  visible: imageTaken,
                  child: Padding(
                      padding: EdgeInsets.only(top: 55),
                      child: CircleAvatar(
                        radius: 150,
                        backgroundImage: FileImage(imagePath),
                      )),
                ),
              ]))),
          Padding(
              padding: EdgeInsets.only(top: 590),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      visible: !imageTaken,
                      child: ElevatedButton(
                          child: Icon(Icons.camera),
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: Colors.white)))),
                          onPressed: () async {
                            final image = await controller.takePicture();
                            imagePath = File(image.path);

                            setState(() {
                              imageTaken = true;
                            });
                          })),
                  Visibility(
                    visible: imageTaken,
                    child: ElevatedButton(
                        child: Row(
                          children: [
                            Text("Retake Photo "),
                            Icon(Icons.camera),
                          ],
                        ),
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
                          setState(() {
                            imageTaken = false;
                          });
                        }),
                  )
                ],
              )),
          Visibility(
            visible: imageTaken,
            child: Align(
                alignment: Alignment.bottomCenter,
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(
                    width: 300,
                    height: 40,
                    child: ElevatedButton(
                        child: Text('Next'),
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
                          if (imagePath != File('')) {
                            Navigator.of(context).pushReplacement(
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        FinalDetails(imagePath)));
                          } else {
                            showAlertDialog(
                                context, "Please Take a Photo!", "Error");
                          }
                        }),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: TextButton(
                          onPressed: () async {
                            fullNameSignup.clear();
                            emailAdress.clear();
                            pwd.clear();
                            confirmpwd.clear();
                            signupToken.clear();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Back To Login",
                            style: TextStyle(color: Colors.white),
                          ))),
                ])),
          ),
        ],
      ),
    );
  }
}

class P extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.8), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Clip extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    print(size);
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, size.height / 2 - 150, 300, 300),
          Radius.circular(200)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    return true;
  }
}

class FinalDetails extends StatefulWidget {
  final File image;
  FinalDetails(this.image);

  @override
  _FinalDetails createState() => _FinalDetails();
}

class _FinalDetails extends State<FinalDetails> {
  bool isButtonClicked = false;

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
          Visibility(
              visible: isButtonClicked,
              child: Center(
                  child: Padding(
                      padding: EdgeInsets.only(top: 55),
                      child: CircularProgressIndicator(color: Colors.white)))),
          Visibility(
              visible: !isButtonClicked,
              child: Container(
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                    Padding(
                      padding: EdgeInsets.only(top: 55, left: 30, right: 0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Photo:",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.w900),
                          )),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: CircleAvatar(
                          radius: 150,
                          backgroundImage: FileImage(widget.image),
                        )),
                    Padding(
                      padding: EdgeInsets.only(top: 25, left: 30, right: 0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Full Name:",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: TextFormField(
                        controller: fullNameSignup,
                        style: TextStyle(color: Colors.white),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Icon(
                                CupertinoIcons.person_alt_circle,
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
                            hintText: "Please enter your Name",
                            fillColor: Colors.white12),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 25, left: 30, right: 0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email:",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900),
                          )),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: TextFormField(
                        controller: emailAdress,
                        style: TextStyle(color: Colors.white),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                              ),
                              child: Icon(
                                CupertinoIcons.envelope_circle_fill,
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
                            hintText: "Please enter your Email",
                            fillColor: Colors.white12),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 55),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 300,
                                height: 40,
                                child: ElevatedButton(
                                    child: Text('Confirm Details'),
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
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                side: BorderSide(
                                                    color: Colors.white)))),
                                    onPressed: () async {
                                      setState(() {
                                        isButtonClicked = true;
                                      });

                                      HttpsCallable callable = FirebaseFunctions
                                          .instance
                                          .httpsCallable('addUserFromSignUp');

                                      try {
                                        final resp = await callable
                                            .call(<String, String>{
                                          'token': signupToken.text.trim(),
                                          'devid': identifier,
                                          'fN': fullNameSignup.text,
                                          'Useremail': emailAdress.text.trim(),
                                          'Userpassword': pwd.text,
                                        });

                                        print(resp.data);
                                        if (resp.data == "User Created") {
                                          await FirebaseAuth.instance
                                              .signInWithEmailAndPassword(
                                                  email:
                                                      emailAdress.text.trim(),
                                                  password: pwd.text);
                                          var url = await uploadFile(
                                              widget.image,
                                              fullNameSignup.text);
                                          await FirebaseFirestore.instance
                                              .collection("Users")
                                              .doc(FirebaseAuth
                                                  .instance.currentUser?.uid)
                                              .update({
                                            'Photo': url,
                                            'imageUploaded': true,
                                            'modifiedType': "ADDED"
                                          });
                                          fullNameSignup.clear();
                                          emailAdress.clear();
                                          pwd.clear();
                                          confirmpwd.clear();
                                          signupToken.clear();
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pushReplacement(
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      UserDashUI()));
                                        } else {
                                          showAlertDialog(context,
                                              resp.data.toString(), "Error");
                                        }
                                      } on FirebaseFunctions catch (e) {
                                        showAlertDialog(
                                            context, e.toString(), "Error");
                                      } catch (e) {
                                        showAlertDialog(
                                            context, e.toString(), "Error");
                                      }
                                    }),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: TextButton(
                                      onPressed: () async {
                                        fullNameSignup.clear();
                                        emailAdress.clear();
                                        pwd.clear();
                                        confirmpwd.clear();
                                        signupToken.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Back To Login",
                                        style: TextStyle(color: Colors.white),
                                      ))),
                            ])),
                  ]))))
        ]));
  }
}

Future<String> uploadFile(
  File portrait,
  String fN,
) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('Users/$fN/${fN + '.jpg'}');
  UploadTask uploadTask = ref.putFile(portrait);
  String picURL;
  picURL = await (await uploadTask).ref.getDownloadURL();
  return picURL;
}
