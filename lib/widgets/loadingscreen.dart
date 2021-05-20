import 'package:flutter/material.dart';

Future<dynamic> loadingScreen(context) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
              content: Container(
            height: height / 3,
            width: width,
            child: Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue[800]),
              ),
            ),
          )));
}
