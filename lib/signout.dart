import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_ca_management_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "./services/dbcollection.dart";

final FirebaseAuth _auth = FirebaseAuth.instance;

signOut(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.get('tokenId');

  dbCollection
      .collection(prefs.get('companyId'))
      .doc("UserDocument")
      .collection("UserCollection")
      .doc(_auth.currentUser.uid)
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
            Navigator.pop(context);
            customSnackBar(
                context, "Singed Out Successfully", Colors.grey[800], 3);
            Navigator.pushAndRemoveUntil(
                context,
                new MaterialPageRoute(builder: (context) => SignInPage()),
                (route) => false);
          }));
}
