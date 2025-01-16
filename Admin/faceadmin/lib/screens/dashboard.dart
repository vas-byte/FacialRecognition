import 'package:flutter/material.dart';
import 'maindash.dart';
import 'users.dart';
import 'history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'chat.dart';
import 'qr.dart';

class Dash extends StatefulWidget {
  @override
  _Dash createState() => _Dash();
}

class _Dash extends State<Dash> {
  void initState() {
    super.initState();
    FirebaseMessaging.instance.subscribeToTopic("detect");
    FirebaseMessaging.instance.getToken().then((value) {
      print(value);
    });
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

  int _selectedIndex = 0;
  final firestoreInstance = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _children = [
    MainDashUI(),
    Users(),
    Chat(),
    Qr(),
    History(),
  ];

  @override
  Widget build(BuildContext context) {
    final _child = _children[_selectedIndex];
    return Scaffold(
      body: _child,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: (() {
            if (MediaQuery.of(context).platformBrightness == Brightness.light) {
              return Colors.grey[100];
            }
          }()),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.red[900],
          unselectedItemColor: Colors.red[300],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'QrCode',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
