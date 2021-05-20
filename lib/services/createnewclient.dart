import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore dbCollection = FirebaseFirestore.instance;

final GlobalKey<FormState> _addNewClientKey = GlobalKey<FormState>();
final TextEditingController _addNewClientController = TextEditingController();
final TextEditingController _phoneNumberController = TextEditingController();
final TextEditingController _gstNumberController = TextEditingController();

Widget createNewClientWidget() {
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
              "Add New Client",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _addNewClientKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _addNewClientController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(
                        Icons.business_outlined,
                      ),
                    ),
                    validator: (String value) {
                      print("_addNewClientController" + value);
                      if (value.isEmpty) return 'Please enter some text';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_android_outlined),
                    ),
                    validator: (String value) {
                      print("_phoneNumberController" + value);
                      if (value.isEmpty) return 'Please enter some text';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _gstNumberController,
                    decoration: const InputDecoration(
                      labelText: 'GST #',
                      prefixIcon: Icon(
                        Icons.work_outline_outlined,
                      ),
                    ),
                    validator: (String value) {
                      print("_gstNumberController" + value);
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

Future<bool> createNewClientFn(String companyId) async {
  try {
    if (_addNewClientKey.currentState.validate()) {
      //dbCollection.collection(companyId).doc("ClientsDocument").set({});

      dbCollection
          .collection(companyId)
          .doc("ClientsDocument")
          .collection("ClientsCollection")
          .doc(_addNewClientController.text.trim())
          .set({
        "phoneNumber": _phoneNumberController.text.trim(),
        "GST": _gstNumberController.text.trim()
      }).then((value) {
        _addNewClientController.clear();
        _phoneNumberController.clear();
        _gstNumberController.clear();
      });
    }
  } catch (e) {
    print("ELse");
    return false;
  }
  return true;
}
