import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_ca_management_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../homepage.dart';
import "dbcollection.dart";
import 'savedevicetoken.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseAuthException authException;

createNewClient(String email, String password, String userName,
    String companyName, context) async {
  String deviceToken = "";

  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User user = userCredential.user;

    user.updateProfile(displayName: userName);

    if (user.uid != null) {
      var checkCompanyCollection =
          await dbCollection.collection(companyName).get();

      if (checkCompanyCollection.docs.isEmpty) {
        CollectionReference userCollection = dbCollection
            .collection(companyName)
            .doc("UserDocument")
            .collection("UserCollection");

        await userCollection.doc(user.uid).set({
          'uniqueCompanyId': companyName,
          'name': userName,
          'isAdmin': true,
          "email": email
        }).then((value) => saveDeviceToken().then((token) async {
              deviceToken = token;
              await userCollection.doc(user.uid).update({
                "token": FieldValue.arrayUnion([deviceToken])
              });
              await dbCollection
                  .collection(companyName)
                  .doc("UserDocument")
                  .set({});

              await dbCollection
                  .collection(companyName)
                  .doc("JobDocument")
                  .set({});

              var today = DateTime.now();
              var subscriptionEndDate = today.add(Duration(days: 7));

              await dbCollection
                  .collection(companyName)
                  .doc("Subscription")
                  .set({
                "trialApplied": true,
                "subscriptionExpiryIn": 7,
                "subscriptionStartDate": today,
                "subscriptionEndDate": subscriptionEndDate
              });

              prefs.setBool('admin', true);
              prefs.setString('uid', user.uid);
              prefs.setString('email', user.email);
              prefs.setString('empname', userName);
              prefs.setString('tokenId', deviceToken);
              prefs.setString('companyId', companyName);
              Navigator.pop(context);
              customSnackBar(
                  context,
                  "Welcome to TaxBee!!. Enjoy your 7 days of free trial",
                  Colors.lightGreenAccent[400],
                  10);

              Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => HomePage.withMetaData(companyName,
                          user.uid, true, userName, user.email, deviceToken)));
            }));
      } else {
        user.delete();
        Navigator.pop(context);
        customSnackBar(
            context,
            "User not created. Company name already exisits. Please verify",
            Colors.red,
            5);
      }
    }
  } catch (e) {
    Navigator.pop(context);
    authException = e;
    customSnackBar(context, authException.message, Colors.red, 3);
  }
}
