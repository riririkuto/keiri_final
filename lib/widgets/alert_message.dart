import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertMessageDialog {
  static void show(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          title: Text(title,style: TextStyle(fontSize: 20.sp)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK',style: TextStyle(fontSize: 10.sp)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
