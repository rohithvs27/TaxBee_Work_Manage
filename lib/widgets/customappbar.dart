import 'package:flutter/material.dart';

Widget customAppBar(context, name) {
  return AppBar(
    title: Text(
      name,
      style: TextStyle(fontSize: 20),
    ),
    centerTitle: true,
    actions: <Widget>[
      Builder(builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Container(
            child: Image.asset("assets/images/taxbee_logo.png",
                width: 100,
                fit: BoxFit.fitWidth,
                alignment: Alignment.centerRight),
          ),
        );
      })
    ],
  );
}
