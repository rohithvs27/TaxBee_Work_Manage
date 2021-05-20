import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'signin.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore dbCollection = FirebaseFirestore.instance;

Future<bool> signOut(BuildContext context) async {
  bool signedOut;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.get('tokenId');

  dbCollection
      .collection(prefs.get('clientId'))
      .doc("UserDocument")
      .collection("UserCollection")
      .doc(prefs.get('uid'))
      .update({
    "token": FieldValue.arrayRemove([token])
  }).then((value) {
    prefs.remove('uid');
    prefs.remove('admin');
    prefs.remove('empname');
    prefs.remove('email');
    prefs.remove('clientId');
    prefs.remove('token');
  }).then((value) => _auth.signOut().then((value) {
            signedOut = true;
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(builder: (context) => SignInPage()),
                (route) => false);
          }));

  return signedOut;
}
