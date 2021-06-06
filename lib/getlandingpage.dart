import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_ca_management_app/verifyemailpage.dart';

class GetLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<User>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            // logged in using email and password
            print("Email verified: " + snapshot.data.emailVerified.toString());
            return snapshot.data.emailVerified
                ? Container(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: Center(
                      child: Text(snapshot.data.uid),
                    ),
                  )
                : VerifyEmailPage();
          }),
    );
  }
}
