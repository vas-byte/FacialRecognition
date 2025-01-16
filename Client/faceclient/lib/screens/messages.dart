import 'dart:io';
import 'package:faceclient/screens/loading.dart';
import 'package:flutter/material.dart';
import 'userdash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

var message = [];
var sentby = [];
var time = [];

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController messageController = TextEditingController();
  final _controller = ScrollController();
  int builder = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Chat"),
                backgroundColor: Colors.red,
                centerTitle: true,
              ),
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
                  width: double.infinity,
                  color: Colors.red[500],
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            left: 15, top: 10, right: 15, bottom: 10),
                        child: TextField(
                            maxLines: null,
                            controller: messageController,
                            style: TextStyle(color: Colors.black),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              suffixIconConstraints:
                                  BoxConstraints(maxHeight: 42, maxWidth: 42),
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                              ),
                              suffixIcon: FloatingActionButton(
                                shape: CircleBorder(),
                                onPressed: () {
                                  DateTime now = DateTime.now();
                                  FirebaseFirestore.instance
                                      .collection('Group')
                                      .doc('Members')
                                      .collection(FirebaseAuth
                                              .instance.currentUser?.uid ??
                                          "")
                                      .doc('Chats')
                                      .collection('Messages')
                                      .doc()
                                      .set({
                                    "Message": messageController.text,
                                    "TimeDate": DateFormat('yyyy-MM-dd HH:mm a')
                                        .format(now),
                                    "index": snapshot.data.docs.length + 1,
                                    "SentByAdmin": false,
                                  });
                                  notify(userName, messageController.text);
                                  messageController.text = "";
                                },
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                backgroundColor: Colors.red[900],
                                elevation: 1,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.black54),
                            )),
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
                      reverse: true,
                      padding: EdgeInsets.only(bottom: 80),
                      controller: _controller,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return Visibility(
                            visible: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Visibility(
                                    visible: !snapshot.data.docs[index]
                                        ["SentByAdmin"],
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                          constraints:
                                              BoxConstraints(maxWidth: 250),
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 7, 10, 7),
                                          margin: EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.red[600],
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
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
                                    visible: snapshot.data.docs[index]
                                        ["SentByAdmin"],
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                          constraints:
                                              BoxConstraints(maxWidth: 250),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                          margin: EdgeInsets.only(top: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.red[200],
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20)),
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
                            ));
                      },
                    ),
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
        .collection(FirebaseAuth.instance.currentUser?.uid ?? "")
        .doc('Chats')
        .collection('Messages')
        .orderBy('index', descending: true)
        .snapshots();
    return messagedata;
  }

  Future<http.Response> notify(String title, String body) {
    return http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key= Firebase Cloud Messaging API KEY GOES HERE'
      },
      body: jsonEncode(<String, dynamic>{
        "to": "/topics/detect",
        "data": {"message": "This is a Firebase Cloud Messaging Topic Message"},
        "notification": {"body": body, "title": title}
      }),
    );
  }
}
