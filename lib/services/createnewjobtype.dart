import 'package:flutter/material.dart';
import "dbcollection.dart";

final GlobalKey<FormState> _addNewJobTypeKey = GlobalKey<FormState>();
final TextEditingController _addNewJobTypeController = TextEditingController();

Widget createNewJobTypeWidget() {
  return Container(
    width: double.maxFinite,
    child: ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 10),
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Center(
            child: Column(
          children: <Widget>[
            Text(
              "Add New Job Type",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _addNewJobTypeKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: _addNewJobTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Add New Job Type',
                      prefixIcon: Icon(
                        Icons.work_outline_outlined,
                      ),
                    ),
                    validator: (String value) {
                      if (value.isEmpty) return 'Please enter some text';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ))
      ],
    ),
  );
}

Future<bool> createNewJobTypeFn(String companyId) async {
  try {
    print("Try funtion");
    if (_addNewJobTypeController.text.trim().isNotEmpty) {
      print("Value is not empty");
      dbCollection.collection(companyId).doc("JobTypeDocument").set({});
      dbCollection
          .collection(companyId)
          .doc("JobTypeDocument")
          .collection("JobTypeCollection")
          .doc(_addNewJobTypeController.text.trim())
          .set({}).then((value) {
        _addNewJobTypeController.clear();
      });
    } else {
      print("Else condition");
      return false;
    }
  } catch (e) {
    return false;
  }
  return true;
}
