import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faceadmin/firebase_options.dart';
import 'package:flutter/material.dart';
import 'screens/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'package:faceadmin/screens/global.dart';

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
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        brightness: Brightness.light,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
        colorScheme: ColorScheme.light(primary: Colors.red)
            .copyWith(secondary: Colors.red)
            .copyWith(background: Colors.white),
      ),
      darkTheme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(primary: Colors.red)
            .copyWith(secondary: Color.fromARGB(255, 55, 47, 46))
            .copyWith(background: Colors.grey[900]),
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: true,
      home: FutureBuilder(
        future: _initialization, //initialize firebase
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //check if firebase is initialized
            if (FirebaseAuth.instance.currentUser?.uid == null) {
              //checks if user is signed in
              return Login();
            } else {
              FirebaseFirestore.instance
                  .collection('Group')
                  .doc('QR')
                  .collection('record')
                  .get()
                  .then((QuerySnapshot querySnapshot) {
                Locations = [];
                querySnapshot.docs.forEach((doc) {
                  Locations.add(doc["Location"].toString());
                });
              });
              FirebaseFirestore.instance
                  .collection('Users')
                  .where("isAdmin", isEqualTo: false)
                  .get(GetOptions(source: Source.cache))
                  .then((QuerySnapshot querySnapshot) {
                querySnapshot.docs.forEach((doc) {
                  UserNameUID[doc["uid"]] = doc["FullName"];
                });
              });

              return Dash();
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
