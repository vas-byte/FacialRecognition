import 'package:flutter/material.dart';
import 'loading.dart';
import "dart:async";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'tokensignup.dart';
import 'useredit.dart';
import 'global.dart';
import 'package:intl/intl.dart';
import 'expandablefab.dart';
import 'AlertDialogs.dart';

String fullN = "";
String photoUrl = "";
String emailAddr = "";

class Users extends StatefulWidget {
  @override
  _Users createState() => _Users();
}

class _Users extends State<Users> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ExpandableFab(
          distance: 75.0,
          key: UniqueKey(),
          initialOpen: false,
          children: [
            ActionButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => TokenSignup()));
              },
              icon: const Icon(Icons.mail),
              key: UniqueKey(),
              tooltip: '',
            ),
            ActionButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) => Add()));
              },
              icon: const Icon(CupertinoIcons.add),
              key: UniqueKey(),
              tooltip: '',
            ),
          ]),
      appBar: AppBar(
        title: Text("Users"),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .where("isAdmin", isEqualTo: false)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.active) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(children: [
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.person_alt_circle,
                                size: 150,
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Number Of Users",
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Text(
                                              snapshot.data!.docs.length
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  fontWeight:
                                                      FontWeight.bold))))
                                ],
                              )
                            ],
                          ),
                        )),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 10.0, left: 5, right: 5),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ListView.separated(
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
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: EdgeInsets.all(5),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return TextButton(
                                  child: ListTile(
                                    trailing: Icon(
                                      Icons.arrow_right,
                                      color: Colors.grey,
                                    ),
                                    leading: CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage: NetworkImage(
                                          snapshot.data?.docs[index]['Photo'],
                                        )),
                                    title: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        snapshot.data?.docs[index]['FullName'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    fullN =
                                        snapshot.data?.docs[index]["FullName"];
                                    photoUrl =
                                        snapshot.data?.docs[index]["Photo"];
                                    emailAddr =
                                        snapshot.data?.docs[index]["Email"];

                                    Navigator.of(context, rootNavigator: true)
                                        .push(MaterialPageRoute(
                                            builder: (context) => UserInfo(
                                                photoUrl,
                                                fullN,
                                                emailAddr,
                                                snapshot.data?.docs[index]
                                                    ["uid"])));
                                  });
                            }),
                      ),
                    ),
                  ]),
                ],
              );
            } else {
              return Loading(
                key: UniqueKey(),
              );
            }
          }),
    );
  }
}

class UserInfo extends StatefulWidget {
  final String photo;
  final String name;
  final String eaddr;
  final String useruuid;
  const UserInfo(this.photo, this.name, this.eaddr, this.useruuid);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  bool currentTime = true;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("User Info"),
          backgroundColor: Colors.red,
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (result) {
                print(result);
                if (result == "Add Check-in...") {
                  showCheckTime(context, widget.name, widget.useruuid);
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Add Check-in...'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Group')
                .doc("Members")
                .collection(widget.useruuid.trim())
                .doc("Attendance")
                .collection("Record")
                .orderBy('Timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.active) {
                return Container(
                    child: CupertinoScrollbar(
                        child: SingleChildScrollView(
                            physics: ScrollPhysics(),
                            child: Column(
                              children: [
                                Padding(padding: EdgeInsets.only(top: 10)),
                                CircleAvatar(
                                    radius: 100,
                                    backgroundImage: NetworkImage(
                                      widget.photo,
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 15, right: 20, left: 20),
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          widget.name,
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900),
                                        ))),
                                Padding(padding: EdgeInsets.only(top: 5)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
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
                                                    borderRadius: BorderRadius.circular(
                                                        30),
                                                    side: BorderSide(
                                                        color: Colors.red)))),
                                        onPressed: () async {
                                          showAlertDialog2(
                                              context,
                                              widget.name,
                                              widget.photo,
                                              widget.eaddr,
                                              widget.useruuid);
                                        },
                                        child: Icon(
                                          CupertinoIcons.trash,
                                          color: Colors.white,
                                        )),
                                    Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 3)),
                                    TextButton(
                                        child: Icon(CupertinoIcons.pencil,
                                            color: Colors.white),
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
                                                        BorderRadius.circular(
                                                            30),
                                                    side: BorderSide(color: Colors.red)))),
                                        onPressed: () async {
                                          Navigator.of(context).push(
                                              CupertinoPageRoute(
                                                  builder: (context) => Uedit(
                                                      widget.name,
                                                      widget.useruuid)));
                                        }),
                                  ],
                                ),
                                Padding(padding: EdgeInsets.only(top: 35)),
                                Container(
                                  width: double.infinity,
                                  child: ListTile(
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
                                ),
                                Divider(
                                    thickness: 2,
                                    color: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade900
                                        : Colors.grey.shade100),
                                ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                            thickness: 2,
                                            color: MediaQuery.of(context)
                                                        .platformBrightness ==
                                                    Brightness.dark
                                                ? Colors.grey.shade900
                                                : Colors.grey.shade100),
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 3),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder:
                                        (BuildContext context3, int index3) {
                                      return Dismissible(
                                        key: UniqueKey(),
                                        background: Container(
                                            color: Colors.red,
                                            child: Align(
                                                alignment: Alignment(0.9, 0),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 30,
                                                ))),
                                        direction: DismissDirection.endToStart,
                                        onDismissed: (direction) async {
                                          if (snapshot.data?.docs[index3]
                                                  ["isQR"] ==
                                              false) {
                                            var hist = await FirebaseFirestore
                                                .instance
                                                .collection("Group")
                                                .doc("History")
                                                .collection("Attendance")
                                                .where("Timestamp",
                                                    isEqualTo: snapshot
                                                            .data?.docs[index3]
                                                        ["Timestamp"])
                                                .get();
                                            hist.docs[0].reference.delete();

                                            snapshot
                                                .data?.docs[index3].reference
                                                .delete();
                                          } else {
                                            var timestamp = snapshot.data
                                                ?.docs[index3]["Timestamp"];

                                            //fix different timestamps recorded from client app
                                            var hist = await FirebaseFirestore
                                                .instance
                                                .collection("Group")
                                                .doc("History")
                                                .collection("Attendance")
                                                .where("Timestamp",
                                                    isEqualTo: timestamp)
                                                .get();

                                            hist.docs[0].reference.delete();

                                            var qrd = await FirebaseFirestore
                                                .instance
                                                .collection("Group")
                                                .doc("QR")
                                                .collection("record")
                                                .doc(snapshot.data?.docs[index3]
                                                    ["Location"])
                                                .collection("Record")
                                                .where("Timestamp",
                                                    isEqualTo: snapshot
                                                            .data?.docs[index3]
                                                        ["Timestamp"])
                                                .get();
                                            qrd.docs[0].reference.delete();

                                            snapshot
                                                .data?.docs[index3].reference
                                                .delete();
                                          }

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
                                            leading: Icon(
                                              (() {
                                                if (snapshot.data?.docs[index3]
                                                        ["isFace"] ==
                                                    true) {
                                                  return CupertinoIcons.camera;
                                                } else if (snapshot
                                                            .data?.docs[index3]
                                                        ["isQR"] ==
                                                    true) {
                                                  return Icons.qr_code;
                                                } else if (snapshot
                                                            .data?.docs[index3]
                                                        ["isManual"] ==
                                                    true) {
                                                  return Icons.person;
                                                }
                                              }()),
                                            ),
                                            title: Center(
                                                child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text(snapshot.data
                                                                  ?.docs[index3]
                                                              ["date"]),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          7)),
                                                          Text(snapshot.data
                                                                  ?.docs[index3]
                                                              ["time"])
                                                        ]))),
                                            trailing: SizedBox(
                                              width: 65,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(snapshot.data
                                                    ?.docs[index3]["Location"]),
                                              ),
                                            )),
                                      );
                                    }),
                              ],
                            ))));
              } else {
                return Loading(
                  key: UniqueKey(),
                );
              }
            }));
  }

  showCheckTime(BuildContext context, String msg, String uid) {
    Widget okButton = TextButton(
      child: Text("Next", style: TextStyle(color: Colors.red)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        showLocationOpt(context, uid, selectedTime, selectedDate);
      },
    );

    Widget noButton = TextButton(
      child: Text("Cancel", style: TextStyle(color: Colors.red)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(msg),
      content: StatefulBuilder(
        builder: (context2, setState2) {
          return Container(
            height: () {
              if (Platform.isAndroid) {
                return 230.0;
              } else if (Platform.isIOS) {
                return 250.0;
              }
            }(),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Use System time:"),
                  Switch(
                      value: currentTime,
                      onChanged: (value) {
                        setState2(() {
                          print(value);
                          selectedDate = DateTime.now();
                          selectedTime = TimeOfDay.now();
                          currentTime = value;
                        });
                      }),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Date:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
              ),
              (() {
                if (currentTime) {
                  return Text(DateFormat('yyyy-MM-dd').format(selectedDate),
                      style: TextStyle(fontSize: 20));
                } else {
                  return SizedBox(
                    height: 35,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final DateTime? selected = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2010),
                          lastDate: DateTime.now(),
                        );
                        if (selected != null && selected != selectedDate)
                          setState2(() {
                            selectedDate = selected;
                          });
                      },
                      child: Text(DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: TextStyle(fontSize: 20)),
                    ),
                  );
                }
              }()),
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Time:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5),
              ),
              (() {
                if (currentTime) {
                  final localizations = MaterialLocalizations.of(context);
                  final formattedTimeOfDay =
                      localizations.formatTimeOfDay(selectedTime);
                  return Text(formattedTimeOfDay,
                      style: TextStyle(fontSize: 20));
                } else {
                  return SizedBox(
                    height: 35,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final TimeOfDay? timeOfDay = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          initialEntryMode: TimePickerEntryMode.dial,
                        );
                        if (timeOfDay != null && timeOfDay != selectedTime) {
                          setState2(() {
                            selectedTime = timeOfDay;
                          });
                        }
                      },
                      child: Text(
                          MaterialLocalizations.of(context)
                              .formatTimeOfDay(selectedTime),
                          style: TextStyle(fontSize: 20)),
                    ),
                  );
                }
              }()),
            ]),
          );
        },
      ),
      actions: [noButton, okButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}

showLocationOpt(
    BuildContext context, String uuid, TimeOfDay time, DateTime date) {
  String dropVal = Locations.first;

  Widget okButton = TextButton(
    child: Text("Add Check-in", style: TextStyle(color: Colors.red)),
    onPressed: () async {
      await FirebaseFirestore.instance
          .collection('Group')
          .doc('Members')
          .collection(uuid)
          .doc('Attendance')
          .collection('Record')
          .doc()
          .set({
        "date": DateFormat('yyyy-MM-dd').format(date),
        "time": MaterialLocalizations.of(context).formatTimeOfDay(time),
        "DateTime": DateFormat('yyyy-MM-dd h:mm a').format(
            DateTime(date.year, date.month, date.day, time.hour, time.minute)),
        "Location": dropVal,
        "isQR": false,
        "isFace": false,
        "isManual": true,
        "Timestamp": Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, time.hour, time.minute)),
      });
      await FirebaseFirestore.instance
          .collection('Group')
          .doc('History')
          .collection('Attendance')
          .doc()
          .set({
        "date": DateFormat('yyyy-MM-dd').format(date),
        "time": MaterialLocalizations.of(context).formatTimeOfDay(time),
        "DateTime": DateFormat('yyyy-MM-dd h:mm a').format(
            DateTime(date.year, date.month, date.day, time.hour, time.minute)),
        "Location": dropVal,
        //"FullName": userName,

        "isQR": false,
        "isFace": false,
        "isManual": true,
        "Timestamp": Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, time.hour, time.minute)),
        "uid": uuid
      });

      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  Widget noButton = TextButton(
    child: Text("Cancel", style: TextStyle(color: Colors.red)),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  Widget list = Container(
      width: double.maxFinite,
      child: SingleChildScrollView(
          child: DropdownButton(
              value: Locations.first,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: Locations.map<DropdownMenuItem<String>>((value) {
                return DropdownMenuItem(
                  value: value.toString(),
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (newValue) {
                print(newValue);
              })));

  AlertDialog alert = AlertDialog(
    title: Text("Select a Location"),
    content: list,
    actions: [noButton, okButton],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

class Add extends StatefulWidget {
  @override
  _Add createState() => _Add();
}

class _Add extends State<Add> {
  File _imageFile = File('/images/images.png');
  bool imageExists = false;
  TextEditingController fullName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool buttonClicked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Add user"), backgroundColor: Colors.red),
        body: Container(
            child: SingleChildScrollView(
                child: Column(
          children: [
            Padding(
                padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                child: Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Full Name:',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      )),
                  TextFormField(
                      controller: fullName,
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
            Padding(
                padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                child: Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Email:',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      )),
                  TextFormField(
                      controller: email,
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
            Padding(
                padding: EdgeInsets.only(top: 20, right: 20, left: 20),
                child: Column(children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Password:',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      )),
                  TextFormField(
                      controller: password,
                      obscureText: true,
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
            Padding(
              padding: EdgeInsets.only(top: 35, right: 20, left: 20),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Photo:',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      )),
                  Visibility(
                    visible: imageExists,
                    child: Image.file(_imageFile),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                        child: Icon(CupertinoIcons.camera),
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: Colors.red)))),
                        onPressed: () {
                          captureImage(ImageSource.camera);
                        }),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                    ElevatedButton(
                        child: Icon(CupertinoIcons.photo),
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: Colors.red)))),
                        onPressed: () {
                          captureImage(ImageSource.gallery);
                        }),
                  ]),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 25, bottom: 10),
                child: Visibility(
                  visible: !buttonClicked,
                  child: SizedBox(
                      height: 45,
                      width: 150,
                      child: ElevatedButton(
                          child: Text("Create User"),
                          style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.red),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      side: BorderSide(color: Colors.red)))),
                          onPressed: () async {
                            if (fullName.text == "") {
                              showAlertDialog(context, "Full Name ");
                            } else if (imageExists == false) {
                              showAlertDialog(context, "Photo ");
                            } else if (email.text == "") {
                              showAlertDialog(context, "Email");
                            } else if (password.text == "") {
                              showAlertDialog(context, "Password");
                            } else {
                              setState(() {
                                buttonClicked = !buttonClicked;
                              });

                              uploadFile(
                                  _imageFile, fullName.text, email.text.trim());
                            }
                          })),
                )),
            Visibility(
              child: LinearProgressIndicator(),
              visible: buttonClicked,
            )
          ],
        ))));
  }

  Future<void> captureImage(ImageSource imageSource) async {
    try {
      final imageFile = await ImagePicker().pickImage(source: imageSource);
      setState(() {
        if (imageFile != null) {
          _imageFile = File(imageFile.path);
          imageExists = true;
        } else {
          imageExists = false;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadFile(File portrait, String fN, String emailAddr) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('Users/$fN/${fN + '.jpg'}');
    UploadTask uploadTask = ref.putFile(portrait);
    String picURL;
    picURL = await (await uploadTask).ref.getDownloadURL();

    print([
      emailAddr,
      picURL,
      fN,
      password.text,
      FirebaseAuth.instance.currentUser?.uid,
    ]);

    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('addUser');

    try {
      final resp = await callable.call(<String, String>{
        'uid': FirebaseAuth.instance.currentUser?.uid ?? "",
        'Useremail': emailAddr.trim(),
        'picURL': picURL,
        'fN': fN,
        'Userpassword': password.text
      });
      print(resp.data);
    } on FirebaseFunctionsException catch (e) {
      print(e.toString());
    } catch (e) {
      print(e.toString());
    }

    Navigator.of(context).pop();
  }
}
