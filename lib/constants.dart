import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

customSnackBar(context, String text, dynamic colors, int timeduration) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: timeduration),
    backgroundColor: colors,
    content: Text(
      text,
      style: TextStyle(
          fontSize: 14,
          fontFamily: "GoogleFonts",
          fontWeight: FontWeight.w500,
          color: Colors.white),
    ),
  ));
}

List<String> jobStatusList = [
  "All",
  "High Priority",
  "Created",
  "InProgress",
  "InReview",
  "Complete"
];
