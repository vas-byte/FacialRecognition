import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faceclient/screens/userdash.dart';
import 'package:flutter/material.dart';
import 'screens/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'screens/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:camera/camera.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(App());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Future<FirebaseApp> _initialization() async {
    cameras = await availableCameras();
    FirebaseApp app = await Firebase.initializeApp();

    if (FirebaseAuth.instance.currentUser != null) {
      var user = await FirebaseFirestore.instance
          .collection("Users")
          .where("uid", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      userName = user.docs[0]["FullName"];
    }

    return app;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: FutureBuilder(
        future: _initialization(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (FirebaseAuth.instance.currentUser == null) {
              return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: MaterialApp(
                      theme: ThemeData(
                          hintColor: Colors.redAccent,
                          brightness: Brightness.light,
                          colorScheme: ColorScheme.light(primary: Colors.red)
                              .copyWith(background: Colors.white)),
                      darkTheme: ThemeData(
                          hintColor: Colors.redAccent,
                          brightness: Brightness.dark,
                          colorScheme: ColorScheme.dark(primary: Colors.red)
                              .copyWith(background: Colors.grey[900])),
                      themeMode: ThemeMode.system,
                      useInheritedMediaQuery: true,
                      home: Login()));
            } else {
              FirebaseMessaging.instance.subscribeToTopic(
                  FirebaseAuth.instance.currentUser!.uid.toLowerCase());

              return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: MaterialApp(
                      theme: ThemeData(
                          hintColor: Colors.redAccent,
                          brightness: Brightness.light,
                          colorScheme: ColorScheme.light(primary: Colors.red)
                              .copyWith(background: Colors.white)),
                      darkTheme: ThemeData(
                          hintColor: Colors.redAccent,
                          brightness: Brightness.dark,
                          colorScheme: ColorScheme.dark(primary: Colors.red)
                              .copyWith(background: Colors.grey[900])),
                      themeMode: ThemeMode.system,
                      useInheritedMediaQuery: true,
                      home: UserDashUI()));
            }
          }

          return Loading(
            key: UniqueKey(),
          );
        },
      ),
    );
  }
}
