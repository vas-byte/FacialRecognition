import 'dart:io';
import 'package:flutter/material.dart';
import 'loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:core';
import 'dart:convert';
import 'package:intl/intl.dart';

String name = "";
String photo = "";
String email = "";
String userID = "";

class Chat extends StatefulWidget {
  @override
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red, title: Text("Chat")),
      body: FutureBuilder(
          future: getChats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 5, right: 5),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Divider(
                            thickness: 2,
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100),
                      );
                    },
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    padding: EdgeInsets.all(5),
                    itemBuilder: (BuildContext context3, int index) {
                      return TextButton(
                          onPressed: () {},
                          child: ListTile(
                            trailing: Icon(Icons.arrow_right),
                            leading: CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage(
                                  snapshot.data.docs[index]['Photo'],
                                )),
                            title: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                snapshot.data.docs[index]['FullName'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () {
                              name = snapshot.data.docs[index]['FullName'];
                              photo = snapshot.data.docs[index]['Photo'];
                              email = snapshot.data.docs[index]['Email'];
                              userID = snapshot.data.docs[index]["uid"];

                              Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                      builder: (context) => Mesgview(
                                          name, photo, email, userID)));
                            },
                          ));
                    },
                  ),
                ),
              );
            } else {
              return Loading(
                key: UniqueKey(),
              );
            }
          }),
    );
  }

  Future getChats() {
    var users = FirebaseFirestore.instance
        .collection('Users')
        .where("isAdmin", isEqualTo: false)
        .get();
    return users;
  }
}

class Mesgview extends StatefulWidget {
  final String fullName;
  final String photo;
  final String eadr;
  final String uuid;
  Mesgview(this.fullName, this.photo, this.eadr, this.uuid);
  @override
  _Mesgview createState() => _Mesgview();
}

class _Mesgview extends State<Mesgview> {
  TextEditingController messageController = TextEditingController();
  ScrollController _controller = ScrollController();
  int builder = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done ||
              snapshot.connectionState == ConnectionState.active) {
            return Scaffold(
              bottomNavigationBar: (() {
                if (Platform.isIOS) {
                  return Container(
                    color: Colors.red,
                    height: 30,
                  );
                } else
                  return null;
              }()),
              bottomSheet: IntrinsicHeight(
                child: Container(
                  width: double.maxFinite,
                  color: Colors.red,
                  child: Column(
                    children: [
                      Container(
                        // height: 60,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10, bottom: 10, top: 10, right: 10),
                          child: TextField(
                              maxLines: null,
                              style: TextStyle(color: Colors.black),
                              controller: messageController,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                  suffixIconConstraints: BoxConstraints(
                                      maxHeight: 42, maxWidth: 42),
                                  isDense: true,
                                  contentPadding: EdgeInsets.fromLTRB(
                                      15.0, 10.0, 15.0, 10.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: "Write message...",
                                  hintStyle: TextStyle(color: Colors.black54),
                                  suffixIcon: FloatingActionButton(
                                    shape: CircleBorder(),
                                    onPressed: () {
                                      DateTime now = DateTime.now();
                                      FirebaseFirestore.instance
                                          .collection('Group')
                                          .doc('Members')
                                          .collection(widget.uuid)
                                          .doc('Chats')
                                          .collection('Messages')
                                          .doc()
                                          .set({
                                        "Message": messageController.text,
                                        "TimeDate":
                                            DateFormat('yyyy-MM-dd HH:mm a')
                                                .format(now),
                                        "index": snapshot.data.docs.length + 1,
                                        "SentByAdmin": true,
                                      });
                                      notify("Admin", messageController.text,
                                          widget.uuid.toLowerCase());
                                      messageController.text = "";
                                    },
                                    child: Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    backgroundColor: Colors.red[900],
                                    elevation: 1,
                                  ))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Stack(
                  children: <Widget>[
                    ListView.builder(
                      controller: _controller,
                      reverse: true,
                      padding: EdgeInsets.only(top: 100, bottom: 80),
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Visibility(
                                visible: snapshot.data.docs[index]
                                    ["SentByAdmin"],
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 275),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 7, 10, 7),
                                      margin: EdgeInsets.only(top: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.red[600],
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20)),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            snapshot.data.docs[index]
                                                ["TimeDate"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            snapshot.data.docs[index]
                                                ["Message"],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17),
                                          ),
                                        ],
                                      )),
                                )),
                            Visibility(
                                visible: !snapshot.data.docs[index]
                                    ["SentByAdmin"],
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 275),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 7, 10, 7),
                                      margin: EdgeInsets.only(top: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.red[200],
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20)),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            snapshot.data.docs[index]
                                                ["TimeDate"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          Text(
                                            snapshot.data.docs[index]
                                                ["Message"],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17),
                                          ),
                                        ],
                                      )),
                                )),
                          ],
                        );
                      },
                    ),
                    Container(
                        padding: EdgeInsets.only(
                            top: (() {
                              if (Platform.isAndroid) {
                                return 30.0;
                              }

                              return 45.0;
                            }()),
                            bottom: 10),
                        color: Theme.of(context).colorScheme.background,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RawMaterialButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              elevation: 2.0,
                              fillColor: Colors.red,
                              child: Icon(
                                Icons.arrow_left,
                                size: 35.0,
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.all(5.0),
                              shape: CircleBorder(),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5)),
                            CircleAvatar(
                                radius: 30.0,
                                backgroundImage: NetworkImage(widget.photo)),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5)),
                            Text(
                              widget.fullName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            );
          } else {
            return Loading(
              key: UniqueKey(),
            );
          }
        });
  }

  Stream getMessages() {
    var messagedata = FirebaseFirestore.instance
        .collection('Group')
        .doc('Members')
        .collection(widget.uuid)
        .doc('Chats')
        .collection('Messages')
        .orderBy('index', descending: true)
        .snapshots();
    return messagedata;
  }

  Future<http.Response> notify(String title, String body, String topic) {
    return http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=Firebase Cloud Messaging API KEY GOES HERE'
      },
      body: jsonEncode(<String, dynamic>{
        "to": "/topics/$topic",
        "data": {"message": "This is a Firebase Cloud Messaging Topic Message"},
        "notification": {"body": body, "title": title}
      }),
    );
  }
}
