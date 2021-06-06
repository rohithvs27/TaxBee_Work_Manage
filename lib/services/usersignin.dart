import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_ca_management_app/constants.dart';
import 'package:new_ca_management_app/ticketslistpage_emp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dbcollection.dart';
import '../homepage.dart';
import '../ticketslistpage.dart';
import 'savedevicetoken.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseAuthException authException;

userSignin(
    String uniqueCompanyId, String email, String password, context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _auth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((credential) {
      User user = credential.user;

      CollectionReference collectionReference = dbCollection
          .collection(uniqueCompanyId)
          .doc('UserDocument')
          .collection("UserCollection");

      collectionReference.doc(user.uid).get().then((docsnap) => {
            if (docsnap.exists)
              {
                saveDeviceToken().then((token) {
                  collectionReference.doc(user.uid).update({
                    "token": FieldValue.arrayUnion([token])
                  }).then((value) => {
                        prefs.setBool('admin', docsnap.data()['isAdmin']),
                        prefs.setString('uid', user.uid),
                        prefs.setString('email', user.email),
                        prefs.setString('empname', docsnap.data()['name']),
                        prefs.setString('companyId', uniqueCompanyId),
                        prefs.setString('tokenId', token.toString()),
                        Navigator.pop(context),
                        customSnackBar(
                            context,
                            "Welcome to TaxBee Manage ${user.displayName}",
                            Colors.grey[800],
                            3),
                        docsnap.data()['isAdmin']
                            ? Navigator.pushReplacement(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => HomePage.withMetaData(
                                        uniqueCompanyId,
                                        user.uid,
                                        docsnap.data()['isAdmin'],
                                        docsnap.data()['name'],
                                        user.email,
                                        token)))
                            : Navigator.pushReplacement(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => TicketListPageEmp(
                                        docsnap.data()['isAdmin'],
                                        user.uid,
                                        uniqueCompanyId,
                                        docsnap.data()['name'],
                                        user.email)))
                      });
                })
              }
            else
              {
                Navigator.pop(context),
                customSnackBar(
                    context,
                    "Company name $uniqueCompanyId does not exisit",
                    Colors.red,
                    3)
              }
          });
    });
  } catch (e) {
    Navigator.pop(context);
    authException = e;
    customSnackBar(context, authException.message, Colors.red, 3);
  }
}
