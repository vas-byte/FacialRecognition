import 'package:flutter/material.dart';
import 'loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'global.dart';
import 'dart:ui';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';

String qk = "";
String loc = "";

class Qr extends StatefulWidget {
  @override
  _Qr createState() => _Qr();
}

class _Qr extends State<Qr> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //
          Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (context) => Addqr()));
        },
        elevation: 2.0,
        child: Icon(
          Icons.add,
          size: 35.0,
        ),
        shape: CircleBorder(),
      ),
      appBar: AppBar(
        title: Text("QR Code"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder(
          stream: getQR(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active ||
                snapshot.hasData) {
              return SingleChildScrollView(
                  physics: ScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 10.0, left: 5, right: 5),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: ListView.separated(
                              //fix scrolling issues
                              separatorBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Divider(
                                      thickness: 2,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade100),
                                );
                              },
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (BuildContext context3, int index) {
                                return TextButton(
                                    onPressed: () {
                                      qk = snapshot.data.docs[index]["Key"];
                                      loc =
                                          snapshot.data.docs[index]["Location"];
                                      Navigator.of(context, rootNavigator: true)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  Qrinfo(qk, loc)));
                                    },
                                    child: ListTile(
                                      leading: QrImageView(
                                        data: snapshot.data.docs[index]["Key"],
                                        version: QrVersions.auto,
                                        size: 50,
                                        gapless: false,
                                        backgroundColor: Colors.white,
                                      ),
                                      title: Text(snapshot.data.docs[index]
                                          ["Location"]),
                                      trailing: Icon(Icons.arrow_right,
                                          color: Colors.grey),
                                    ));
                              }),
                        ),
                      )
                    ],
                  ));
            } else {
              return Loading(
                key: UniqueKey(),
              );
            }
          }),
    );
  }

  Stream getQR() {
    var users = FirebaseFirestore.instance
        .collection('Group')
        .doc('QR')
        .collection('record')
        .snapshots();
    return users;
  }
}

class Addqr extends StatefulWidget {
  @override
  _Addqr createState() => _Addqr();
}

class _Addqr extends State<Addqr> {
  TextEditingController location = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String randString = getRandomString(25);
    return Scaffold(
        appBar: AppBar(title: Text("Add QR Code"), backgroundColor: Colors.red),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
              child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: QrImageView(
                    data: randString,
                    version: QrVersions.auto,
                    size: 300,
                    gapless: false,
                    backgroundColor: Colors.white,
                  )),
              Padding(
                  padding:
                      EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 50),
                  child: Column(children: [
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Location:',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        )),
                    TextFormField(
                        controller: location,
                        decoration: new InputDecoration(
                          //hintText: "Enter a Full Name",
                          //labelStyle: TextStyle(color: Colors.red),
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
                        )),
                  ])),
              FittedBox(
                fit: BoxFit.contain,
                child: ElevatedButton(
                  child: Text("Create Qr Code"),
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: Colors.red)))),
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection('Group')
                        .doc('QR')
                        .collection('record')
                        .doc(location.text)
                        .set({"Key": randString, "Location": location.text});
                    Locations.add(location.text);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          )),
        ));
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

class Qrinfo extends StatefulWidget {
  final String qrkey;
  final String location;
  Qrinfo(this.qrkey, this.location);

  @override
  _Qrinfo createState() => _Qrinfo();
}

class _Qrinfo extends State<Qrinfo> {
  final GlobalKey qrKeys = GlobalKey();
  bool buttonPress = false;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Group')
            .doc("History")
            .collection("Attendance")
            .where("qrid", isEqualTo: widget.qrkey)
            .orderBy('Timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.connectionState == ConnectionState.active) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("QR Code Information"),
                  backgroundColor: Colors.red,
                ),
                body: CupertinoScrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Visibility(
                            visible: buttonPress,
                            child: Center(
                                child: Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: CircularProgressIndicator(
                                      color: Colors.red,
                                    )))),
                        Visibility(
                          visible: !buttonPress,
                          child: Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: Screenshot(
                                      controller: screenshotController,
                                      key: qrKeys,
                                      child: QrImageView(
                                        data: widget.qrkey,
                                        version: QrVersions.auto,
                                        size: 300,
                                        gapless: false,
                                        backgroundColor: Colors.white,
                                      ))),
                              Padding(
                                  padding: EdgeInsets.only(top: 5),
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        widget.location,
                                        style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold),
                                      ))),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      child: Icon(
                                        CupertinoIcons.square_arrow_down,
                                        color: Colors.white,
                                      ),
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  side: BorderSide(
                                                      color: Colors.red)))),
                                      onPressed: () async {
                                        try {
                                          // Take screenshot
                                          screenshotController
                                              .capture()
                                              .then((Uint8List? image) async {
                                            if (image != null) {
                                              // Share image file
                                              final directory =
                                                  await getApplicationDocumentsDirectory();
                                              final imagePath = await File(
                                                      '${directory.path}/image.png')
                                                  .create();
                                              await imagePath
                                                  .writeAsBytes(image);

                                              // Share Plugin
                                              await Share.shareXFiles(
                                                  [XFile(imagePath.path)]);
                                            } else {
                                              print(
                                                  "Screenshot capture returned null.");
                                            }
                                          }).catchError((onError) {
                                            print(
                                                "Error capturing screenshot: $onError");
                                          });
                                        } catch (e) {
                                          print("Error occurred: $e");
                                        }
                                      }),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 3),
                                  ),
                                  ElevatedButton(
                                      child: Icon(
                                        CupertinoIcons.trash,
                                        color: Colors.white,
                                      ),
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.red),
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  side: BorderSide(
                                                      color: Colors.red)))),
                                      onPressed: () async {
                                        setState(() {
                                          buttonPress = true;
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('Group')
                                            .doc('QR')
                                            .collection('record')
                                            .doc(widget.location)
                                            .delete();
                                        await FirebaseFirestore.instance
                                            .collection('Group')
                                            .doc('History')
                                            .collection('Attendance')
                                            .where("qrid",
                                                isEqualTo: widget.qrkey)
                                            .get()
                                            .then((snapshot) {
                                          for (var x = 0;
                                              x < snapshot.size;
                                              x++) {
                                            snapshot.docs[x].reference.delete();
                                          }
                                          FirebaseFirestore.instance
                                              .collection("Users")
                                              .get()
                                              .then((snapshot2) {
                                            for (var i = 0;
                                                i < snapshot2.size;
                                                i++) {
                                              var uid =
                                                  snapshot2.docs[i]["uid"];
                                              FirebaseFirestore.instance
                                                  .collection('Group')
                                                  .doc('Members')
                                                  .collection(uid)
                                                  .doc('Attendance')
                                                  .collection('Record')
                                                  .where("qrid",
                                                      isEqualTo: widget.qrkey)
                                                  .get()
                                                  .then((snapshot3) {
                                                for (var j = 0;
                                                    j < snapshot3.size;
                                                    j++) {
                                                  snapshot3.docs[j].reference
                                                      .delete();
                                                }
                                              });
                                            }
                                          });
                                        });
                                        Navigator.of(context).pop();
                                      }),
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 20)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Icon(Icons.person),
                                      Text("User")
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(children: [
                                        Icon(Icons.calendar_today),
                                        Icon(Icons.watch)
                                      ]),
                                      Text("Date & Time")
                                    ],
                                  ),
                                ],
                              ),
                              Divider(
                                  thickness: 2,
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100),
                              ListView.separated(
                                  separatorBuilder: (context, index) => Divider(
                                      thickness: 2,
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade900
                                          : Colors.grey.shade100),
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder:
                                      (BuildContext context3, int index2) {
                                    return Dismissible(
                                        background: Container(
                                            color: Colors.red,
                                            child: Align(
                                                alignment: Alignment(0.9, 0),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 30,
                                                ))),
                                        key: UniqueKey(),
                                        direction: DismissDirection.endToStart,
                                        onDismissed: (direction) async {
                                          var hist = await FirebaseFirestore
                                              .instance
                                              .collection("Group")
                                              .doc("History")
                                              .collection("Attendance")
                                              .where("Timestamp",
                                                  isEqualTo: snapshot
                                                          .data?.docs[index2]
                                                      ["Timestamp"])
                                              .get();
                                          hist.docs[0].reference.delete();
                                          var us = await FirebaseFirestore
                                              .instance
                                              .collection("Group")
                                              .doc("Members")
                                              .collection(snapshot
                                                  .data?.docs[index2]["uid"])
                                              .doc("Attendance")
                                              .collection("Record")
                                              .where("Timestamp",
                                                  isEqualTo: snapshot
                                                          .data?.docs[index2]
                                                      ["Timestamp"])
                                              .get();
                                          us.docs[0].reference.delete();

                                          snapshot.data?.docs[index2].reference
                                              .delete();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  backgroundColor: Colors.red,
                                                  duration: const Duration(
                                                      seconds: 1),
                                                  content: Text(
                                                      'Check-in Removed',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))));
                                        },
                                        child: ListTile(
                                            leading: SizedBox(
                                                width: 120,
                                                child: Text(
                                                  (() {
                                                    try {
                                                      return UserNameUID[
                                                          snapshot.data
                                                                  ?.docs[index2]
                                                              ["uid"]];
                                                    } catch (e) {
                                                      setState(() {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('Users')
                                                            .where("isAdmin",
                                                                isEqualTo:
                                                                    false)
                                                            .get(GetOptions(
                                                                source: Source
                                                                    .serverAndCache))
                                                            .then((QuerySnapshot
                                                                querySnapshot) {
                                                          querySnapshot.docs
                                                              .forEach((doc) {
                                                            UserNameUID[doc[
                                                                    "uid"]] =
                                                                doc["FullName"];
                                                          });
                                                        });
                                                      });
                                                    }
                                                  }()),
                                                  textAlign: TextAlign.start,
                                                )),
                                            title: Center(
                                                child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text(snapshot.data
                                                                  ?.docs[index2]
                                                              ["date"]),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          15)),
                                                          Text(snapshot.data
                                                                  ?.docs[index2]
                                                              ["time"])
                                                        ])))));
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          } else {
            return Loading(
              key: UniqueKey(),
            );
          }
        });
  }
}
