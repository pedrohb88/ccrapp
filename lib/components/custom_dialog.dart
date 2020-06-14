import 'package:flutter/material.dart';

class CustomDialog {
  final String msg;

  CustomDialog({@required this.msg}) : assert(msg != null);

  show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(this.msg),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
    });
  }
}
