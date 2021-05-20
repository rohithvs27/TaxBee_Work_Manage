import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore dbCollection = FirebaseFirestore.instance;
String _user;
Widget deleteUserWidget(String companyId) {
  return Container(
    width: double.maxFinite,
    child: ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 10),
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            getEmpList(companyId),
          ],
        )
      ],
    ),
  );
}

StreamBuilder<QuerySnapshot> getEmpList(String companyId) {
  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(companyId)
          .doc("UserDocument")
          .collection("UserCollection")
          .where("name", isNotEqualTo: "Admin User")
          .snapshots(),
      builder: (context, snapshot) {
        List<DropdownMenuItem> userList = [];
        if (!snapshot.hasData) {
          Text("Loading");
        } else {
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            userList.add(DropdownMenuItem(
              child: Text(snapshot.data.docs[i]["name"]),
              value: snapshot.data.docs[i]["name"],
            ));
          }
        }
        return DropdownButtonFormField(
            autovalidateMode: AutovalidateMode.always,
            isExpanded: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.person_remove_outlined,
                // color: Color(0xFF003580),
              ),
            ),
            hint: Text("Select User to Delete"),
            items: userList,
            onChanged: (user) {
              _user = user;
            },
            value: _user,
            validator: (var value) {
              if (value == null) return 'Please Select User';
              return null;
            });
      });
}

Future<String> deleteUserFn(String companyId, String username) async {
  String status;
  try {
    if (username != null) {
      await dbCollection
          .collection(companyId)
          .doc("JobDocument")
          .collection("JobCollection")
          .where("employee.assignedTo", arrayContains: username)
          .get()
          .then((snapshot) async {
        //Condition to check if there are any open jobs for the employee to be deleted
        //Delete only "NO"
        if (snapshot.docs.isEmpty) {
          await dbCollection
              .collection(companyId)
              .doc("UserDocument")
              .collection("UserCollection")
              .where("name", isEqualTo: username)
              .get()
              .then((snapshot) async {
            if (snapshot.docs.isNotEmpty) {
              snapshot.docs.forEach((doc) async {
                print("doc:" + doc.toString());
                doc.reference.delete();
              });
            }
          });
          status = "true";
        } else {
          status = "job_open";
        }
      });
    }
    return status;
  } catch (e) {
    status = e.toString();
    return status;
  }
}
