import 'package:flutter/material.dart';
import 'loading.dart';
import "dart:async";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DeleteUser extends StatefulWidget {
  final String name;
  final String photo;
  final String eadr;
  final String useruid;

  DeleteUser(this.name, this.photo, this.eadr, this.useruid);

  @override
  _DeleteUser createState() => _DeleteUser();
}

class _DeleteUser extends State<DeleteUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        width: double.infinity,
        height: 100,
        child: Center(
          child: SizedBox(
            height: 70,
            width: 300,
            child: ElevatedButton(
                child: Text("Ok"),
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(color: Colors.green)))),
                onPressed: () async {
                  Navigator.of(context).pop();
                }),
          ),
        ),
      ),
      body: FutureBuilder(
          future: deleteUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done ||
                snapshot.hasData) {
              return Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25, bottom: 15),
                    child: Icon(
                      CupertinoIcons.person_alt_circle,
                      size: 350,
                    ),
                  ),
                  Text(
                    "User Deleted",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 55),
                  ),
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

  Future<bool> deleteUser() async {
    FirebaseStorage.instance.refFromURL(widget.photo).delete();

    final firestore = FirebaseFirestore.instance;

    await firestore.collection('Users').doc(widget.useruid).delete();
    await firestore
        .collection('Group')
        .doc('Members')
        .collection(widget.useruid)
        .doc('Attendance')
        .delete();

    var docshot = await firestore
        .collection('Group')
        .doc('History')
        .collection('Attendance')
        .where("uid", isEqualTo: widget.useruid)
        .get();
    for (var doc in docshot.docs) {
      await doc.reference.delete();
    }

    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('deleteUser');
    final resp = await callable.call(<String, String>{
      'text': widget.useruid,
      'uid': FirebaseAuth.instance.currentUser?.uid ?? "",
    });

    return true;
  }
}
