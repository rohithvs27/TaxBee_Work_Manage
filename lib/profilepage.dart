import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'widgets/customappbar.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

TextStyle customLeftStyle = TextStyle(
  fontSize: 16,
);
TextStyle customRightStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

class UserProfile extends StatelessWidget {
  final String companyId;

  UserProfile(this.companyId);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: customAppBar(context, "Profile"),
      extendBodyBehindAppBar: true,
      body: Container(
        margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: ListView(
          addAutomaticKeepAlives: true,
          children: [
            ProfileContainer("Company Name", companyId),
            ProfileContainer("Name", _auth.currentUser.displayName),
            ProfileContainer("email", _auth.currentUser.email),
          ],
        ),
      ),
    ));
  }
}

class ProfileContainer extends StatelessWidget {
  final String title;
  final String value;

  ProfileContainer(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        margin: EdgeInsets.all(10),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: customLeftStyle,
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: customRightStyle,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
