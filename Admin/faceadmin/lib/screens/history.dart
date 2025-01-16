import 'dart:io';

import 'package:flutter/material.dart';
import 'loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'global.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  @override
  _History createState() => _History();
}

class _History extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (result) {
              print(result);
              if (result == "Add Check-in...") {
                showAddUserDialog(context, ";)");
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
              .doc("History")
              .collection("Attendance")
              .orderBy('Timestamp', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return Container(
                  child: CupertinoScrollbar(
                      child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.only(top: 5, bottom: 6, right: 0, left: 0),
                      //scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      //reverse: false,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context3, int index3) {
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
                            print(index3);
                            print(snapshot.data?.docs[index3]["Timestamp"]);

                            if (snapshot.data?.docs[index3]["isQR"] == false) {
                              var us = await FirebaseFirestore.instance
                                  .collection("Group")
                                  .doc("Members")
                                  .collection(
                                      snapshot.data?.docs[index3]["uid"])
                                  .doc("Attendance")
                                  .collection("Record")
                                  .where("Timestamp",
                                      isEqualTo: snapshot.data?.docs[index3]
                                          ["Timestamp"])
                                  .get();

                              us.docs[0].reference.delete();
                              snapshot.data?.docs[index3].reference.delete();
                            } else {
                              var us = await FirebaseFirestore.instance
                                  .collection("Group")
                                  .doc("Members")
                                  .collection(
                                      snapshot.data?.docs[index3]["uid"])
                                  .doc("Attendance")
                                  .collection("Record")
                                  .where("Timestamp",
                                      isEqualTo: snapshot.data?.docs[index3]
                                          ["Timestamp"])
                                  .get();
                              us.docs[0].reference.delete();
                              var qrd = await FirebaseFirestore.instance
                                  .collection("Group")
                                  .doc("QR")
                                  .collection("record")
                                  .doc(snapshot.data?.docs[index3]["Location"])
                                  .collection("Record")
                                  .where("Timestamp",
                                      isEqualTo: snapshot.data?.docs[index3]
                                          ["Timestamp"])
                                  .get();
                              qrd.docs[0].reference.delete();
                              snapshot.data?.docs[index3].reference.delete();
                            }

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 1),
                                content: Text('Check-in Removed',
                                    style: TextStyle(color: Colors.white))));
                          },
                          child: ListTile(
                            leading: Icon(
                              (() {
                                if (snapshot.data?.docs[index3]["isFace"] ==
                                    true) {
                                  return CupertinoIcons.camera;
                                } else if (snapshot.data?.docs[index3]
                                        ["isQR"] ==
                                    true) {
                                  return Icons.qr_code;
                                } else if (snapshot.data?.docs[index3]
                                        ["isManual"] ==
                                    true) {
                                  return Icons.person;
                                }
                              }()),
                              size: 56.0,
                              color: (() {
                                if (MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark) {
                                  return Colors.white;
                                } else {
                                  return Colors.black;
                                }
                              }()),
                            ),
                            title: Text(
                              (() {
                                try {
                                  return UserNameUID[snapshot.data?.docs[index3]
                                      ["uid"]];
                                } catch (e) {
                                  setState(() {
                                    FirebaseFirestore.instance
                                        .collection('Users')
                                        .where("isAdmin", isEqualTo: false)
                                        .get(GetOptions(
                                            source: Source.serverAndCache))
                                        .then((QuerySnapshot querySnapshot) {
                                      querySnapshot.docs.forEach((doc) {
                                        UserNameUID[doc["uid"]] =
                                            doc["FullName"];
                                      });
                                    });
                                  });
                                }
                              }()),
                              style: TextStyle(
                                color: (() {
                                  if (MediaQuery.of(context)
                                          .platformBrightness ==
                                      Brightness.dark) {
                                    return Colors.white;
                                  } else {
                                    return Colors.black;
                                  }
                                }()),
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  snapshot.data?.docs[index3]["date"],
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: (() {
                                        if (MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark) {
                                          return Colors.white;
                                        } else {
                                          return Colors.black;
                                        }
                                      }()),
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                ),
                                Text(snapshot.data?.docs[index3]["time"],
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: (() {
                                          if (MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark) {
                                            return Colors.white;
                                          } else {
                                            return Colors.black;
                                          }
                                        }()),
                                        fontWeight: FontWeight.bold))
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                            thickness: 1,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100);
                      },
                    ),
                  )),
                );
              } else {
                return Center(
                  child: Text("No Data"),
                );
              }
            } else {
              return Loading(
                key: UniqueKey(),
              );
            }
          }),
    );
  }

  showAddUserDialog(BuildContext context, String errmesg) {
    Widget okButton = TextButton(
      child: Text("OK", style: TextStyle(color: Colors.red)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget list = Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
            child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                    thickness: 2,
                    color: MediaQuery.of(context).platformBrightness ==
                            Brightness.dark
                        ? Colors.grey.shade900
                        : Colors.grey.shade100),
                shrinkWrap: true,
                itemCount: UserNameUID.length,
                itemBuilder: (BuildContext context4, int index4) {
                  return TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        showCheckTime(
                            context,
                            UserNameUID.values.toList()[index4],
                            UserNameUID.keys.toList()[index4]);
                      },
                      child: ListTile(
                          title: Text(UserNameUID.values.toList()[index4])));
                })));

    AlertDialog alert = AlertDialog(
      title: Text("Select a User"),
      content: list,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showCheckTime(BuildContext context, String msg, String uid) {
    bool currentTime = true;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

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
                return 230.0;
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
                    height: () {
                      if (Platform.isAndroid) {
                        return 35.0;
                      } else if (Platform.isIOS) {
                        return 35.0;
                      }
                    }(),
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
                    height: () {
                      if (Platform.isAndroid) {
                        return 35.0;
                      } else if (Platform.isIOS) {
                        return 35.0;
                      }
                    }(),
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
  String? dropVal = Locations.first;

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
                dropVal = newValue as String?;
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
