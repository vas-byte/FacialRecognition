import 'package:flutter/material.dart';

showAlertDialog(BuildContext context, String errmesg, String title) {
  Widget okButton = TextButton(
    child: Text("OK", style: TextStyle(color: Colors.red)),
    onPressed: () {
      Navigator.of(context, rootNavigator: true).pop();
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(errmesg),
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
