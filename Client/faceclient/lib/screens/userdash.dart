import 'dart:io';

import 'package:faceclient/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:core';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'messages.dart';

import 'expandablefab.dart';
import 'useredit.dart';

class UserDashUI extends StatefulWidget {
  @override
  _UserDashUI createState() => _UserDashUI();
}

String userName = "";
String photoUrl = "";

class _UserDashUI extends State<UserDashUI> {
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(event.notification?.title ?? ""),
              content: Text(event.notification?.body ?? ""),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getCheckins(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.hasData) {
            return Scaffold(
                floatingActionButton: ExpandableFab(
                  distance: 100,
                  key: UniqueKey(),
                  initialOpen: false,
                  children: [
                    ActionButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Camview()),
                        );
                      },
                      icon: const Icon(Icons.qr_code),
                      key: UniqueKey(),
                      tooltip: '',
                    ),
                    ActionButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (context) => MessageScreen()),
                        );
                      },
                      icon: const Icon(CupertinoIcons.chat_bubble),
                      key: UniqueKey(),
                      tooltip: '',
                    ),
                    ActionButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (context) => Uedit(userName,
                                  FirebaseAuth.instance.currentUser!.uid)),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      key: UniqueKey(),
                      tooltip: '',
                    ),
                    ActionButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Login()));

                        FirebaseAuth.instance.signOut();
                      },
                      key: UniqueKey(),
                      tooltip: '',
                    )
                  ],
                ),
                appBar: AppBar(
                  title: Text("Dashboard"),
                  backgroundColor: Colors.red,
                ),
                body: Container(
                    child: CupertinoScrollbar(
                        child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              children: [
                                StreamBuilder(
                                    stream: getProfile(),
                                    builder: (context, snapshot2) {
                                      if (snapshot2.connectionState ==
                                              ConnectionState.active ||
                                          snapshot2.hasData) {
                                        return Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                child: CircleAvatar(
                                                    radius: 100.0,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      snapshot2.data.docs[0]
                                                          ["Photo"],
                                                    ))),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 5,
                                                      right: 20,
                                                      left: 20),
                                                  child: Text(
                                                    snapshot2.data.docs[0]
                                                        ["FullName"],
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  )),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }),
                                Padding(
                                  padding: EdgeInsets.only(top: 15),
                                ),
                                ListTile(
                                    leading: Container(
                                      height: 42,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Column(
                                          children: [
                                            Icon(Icons.computer),
                                            Text(
                                              "Type",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    title: Container(
                                      height: 42,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Center(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.calendar_today),
                                                    Icon(Icons.watch)
                                                  ],
                                                ),
                                                Text(
                                                  "Date & Time",
                                                  maxLines: 2,
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    trailing: Container(
                                      height: 42,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Column(
                                          children: [
                                            Icon(Icons.pin_drop),
                                            Text(
                                              "Location",
                                              style: TextStyle(fontSize: 15),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                                Divider(
                                  thickness: 2,
                                ),
                                (() {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: [
                                        ListView.separated(
                                            separatorBuilder: (context, index) {
                                              return Divider(
                                                thickness: 2,
                                              );
                                            },
                                            padding: EdgeInsets.only(top: 2),
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount:
                                                snapshot.data.docs.length,
                                            itemBuilder: (BuildContext context3,
                                                int index3) {
                                              return ListTile(
                                                  leading: Icon((() {
                                                    if (snapshot.data
                                                                .docs[index3]
                                                            ["isFace"] ==
                                                        true) {
                                                      return CupertinoIcons
                                                          .camera;
                                                    } else if (snapshot.data
                                                                .docs[index3]
                                                            ["isQR"] ==
                                                        true) {
                                                      return Icons.qr_code;
                                                    } else if (snapshot.data
                                                                .docs[index3]
                                                            ["isManual"] ==
                                                        true) {
                                                      return Icons.person;
                                                    }
                                                  }())),
                                                  title: Center(
                                                    child: FittedBox(
                                                      //       fit: BoxFit.scaleDown,
                                                      //       child: Text(DateFormat(
                                                      //               'dd-MM-yyyy  hh:mm a')
                                                      //           .format(snapshot
                                                      //               .data
                                                      //               .docs[index3][
                                                      //                   "Timestamp"]
                                                      //               .toDate()))
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(snapshot.data
                                                                    .docs[index3]
                                                                ["date"]),
                                                            Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10)),
                                                            Text(snapshot
                                                                    .data.docs[
                                                                index3]["time"])
                                                          ]),
                                                    ),
                                                  ),
                                                  trailing: SizedBox(
                                                    width: 70,
                                                    child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Center(
                                                          child: Text(
                                                            snapshot.data.docs[
                                                                    index3]
                                                                ["Location"],
                                                            style: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
                                                          ),
                                                        )),
                                                  ));
                                            }),
                                        Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 25))
                                      ],
                                    );
                                  } else {
                                    return Padding(
                                        padding: EdgeInsets.only(top: 15),
                                        child: Text("No Data"));
                                  }
                                }()),
                              ],
                            )))));
          } else {
            return Loading(
              key: UniqueKey(),
            );
          }
        });
  }

  Stream getCheckins() {
    var authdata = FirebaseFirestore.instance
        .collection('Group')
        .doc("Members")
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .doc("Attendance")
        .collection("Record")
        .orderBy('Timestamp', descending: true)
        .snapshots();

    return authdata;
  }
}

Stream getProfile() {
  var userdata = FirebaseFirestore.instance
      .collection('Users')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  return userdata;
}

late List<CameraDescription> cameras;

class Camview extends StatefulWidget {
  @override
  _Camview createState() => _Camview();
}

class _Camview extends State<Camview> with WidgetsBindingObserver {
  late CameraController controller;
  final barcodeScanner = BarcodeScanner();

  @override
  void initState() {
    super.initState();
    getCam();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    controller.dispose();
    barcodeScanner.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();

      barcodeScanner.close();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        controller.dispose();
        getCam();
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = cameras[0];
    final sensorOrientation = camera.sensorOrientation;

    final _orientations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };

    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[controller.value.deviceOrientation];

      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  void getCam() {
    controller = CameraController(
      cameras.first,
      ResolutionPreset.low,
      enableAudio: false,
    );
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((CameraImage availableImage) async {
        InputImage? img = _inputImageFromCameraImage(availableImage);
        List<Barcode> barcodes = [];

        if (img != null) {
          barcodes = await barcodeScanner.processImage(img);
        }

        if (barcodes.isNotEmpty) {
          try {
            controller.stopImageStream();
          } catch (e) {}

          String key = barcodes[0].value.toString();

          var docs = await FirebaseFirestore.instance
              .collection('Group')
              .doc('QR')
              .collection('record')
              .where('Key', isEqualTo: key)
              .get();

          var currentTime = Timestamp.fromDate(DateTime.now());

          if (docs.docs.length != 0) {
            await FirebaseFirestore.instance
                .collection('Group')
                .doc('Members')
                .collection(FirebaseAuth.instance.currentUser!.uid)
                .doc('Attendance')
                .collection('Record')
                .doc()
                .set({
              "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
              "time": DateFormat('h:mma').format(DateTime.now()),
              "DateTime":
                  DateFormat('yyyy-MM-dd h:mm a').format(DateTime.now()),
              "Location": docs.docs[0]["Location"],
              "qrid": key,
              "isQR": true,
              "isFace": false,
              "isManual": false,
              "Timestamp": currentTime,
            });

            await FirebaseFirestore.instance
                .collection('Group')
                .doc('History')
                .collection('Attendance')
                .doc()
                .set({
              "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
              "time": DateFormat('h:mma').format(DateTime.now()),
              "DateTime":
                  DateFormat('yyyy-MM-dd h:mm a').format(DateTime.now()),
              "Location": docs.docs[0]["Location"],
              "qrid": key,
              "isQR": true,
              "isFace": false,
              "isManual": false,
              "Timestamp": currentTime,
              "uid": FirebaseAuth.instance.currentUser?.uid
            });
            barcodeScanner.close();
            barcodes.clear();
            controller.dispose();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => Sucess(docs.docs[0]["Location"])),
            );
          } else {
            barcodeScanner.close();
            barcodes.clear();
            controller.dispose();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Failed()),
            );
          }
        }
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized || controller == null) {
      return Container();
    }
    return Container(
      child: Stack(children: [
        Container(
            child: CameraPreview(controller),
            width: double.infinity,
            height: MediaQuery.of(context).size.height),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ElevatedButton(
                  child: Icon(
                    CupertinoIcons.arrow_left_square,
                    color: Colors.white,
                  ),
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(
                      MaterialPageRoute(builder: (context) => UserDashUI()),
                    );
                  }),
            ))
      ]),
    );
  }
}

class Sucess extends StatelessWidget {
  final String location;
  Sucess(this.location);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 100),
              child: Icon(
                Icons.check_circle,
                size: 200,
                color: Colors.green,
              )),
          Text(
            "Checked In",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40),
          ),
          Text(
            location,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 40),
          ),
          Spacer(),
          SizedBox(
              width: double.infinity,
              height: 85,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 20, left: 30, right: 30),
                  child: ElevatedButton(
                      child: Text("Ok"),
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(color: Colors.green)))),
                      onPressed: () async {
                        Navigator.of(context).pop(
                          MaterialPageRoute(builder: (context) => UserDashUI()),
                        );
                      }))),
        ],
      ),
    ));
  }
}

class Failed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 100),
              child: Icon(
                Icons.remove_circle,
                size: 200,
                color: Colors.red,
              )),
          Text(
            "Check In Failed",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40),
          ),
          Spacer(),
          SizedBox(
              width: double.infinity,
              height: 85,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 20, left: 30, right: 30),
                  child: ElevatedButton(
                      child: Text("Ok"),
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.red),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      side: BorderSide(color: Colors.red)))),
                      onPressed: () async {
                        Navigator.of(context).pop(
                          MaterialPageRoute(builder: (context) => UserDashUI()),
                        );
                      }))),
        ],
      ),
    ));
  }
}
