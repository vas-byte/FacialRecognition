import 'package:flutter/material.dart';
import 'deleteLoading.dart';

showAlertDialog(BuildContext context, String missing) {
  //missing form entries
  Widget okButton = TextButton(
    child: Text("OK", style: TextStyle(color: Colors.red)),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(missing + "Missing"),
    content: Text(
        "Please add your " + missing.toLowerCase() + "using the field above"),
    actions: [
      okButton,
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAlertDialog2(
    //Delete Users
    BuildContext context,
    String name,
    String photo,
    String eadr,
    String uuid) {
  Widget okButton = TextButton(
    child: Text(
      "Ok",
      style: TextStyle(color: Colors.red),
    ),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
              builder: (context) => DeleteUser(name, photo, eadr, uuid)));
    },
  );

  Widget cancelButton = TextButton(
    child: Text("Cancel", style: TextStyle(color: Colors.red)),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text("Delete User"),
    content: Text("Warning: deleted user data cannot be recovered"),
    actions: [okButton, cancelButton],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAlertDialog3(BuildContext context, String error) {
  //Error Dialog
  Widget okButton = TextButton(
    child: Text(
      "Ok",
      style: TextStyle(color: Colors.red),
    ),
    onPressed: () async {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  Widget cancelButton = TextButton(
    child: Text("Cancel", style: TextStyle(color: Colors.red)),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text("Error"),
    content: Text(error),
    actions: [okButton, cancelButton],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
