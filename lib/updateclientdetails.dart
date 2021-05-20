import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:new_ca_management_app/widgets/customappbar.dart';

FirebaseAuthException authException;
FirebaseFirestore dbCollection = FirebaseFirestore.instance;

class UpdateClientDetails extends StatefulWidget {
  final String clientId;
  final editClientobj;

  UpdateClientDetails(this.clientId, this.editClientobj);
  @override
  _UpdateClientDetailsState createState() => _UpdateClientDetailsState();
}

class _UpdateClientDetailsState extends State<UpdateClientDetails>
    with TickerProviderStateMixin {
  AnimationController animationController;
  final GlobalKey<FormState> _clientFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  bool updatingClientInProgress = false;
  String clientId;
  var updateClientId;

  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
    clientId = widget.clientId;
    var updateClientData = widget.editClientobj['data'];
    updateClientId = widget.editClientobj['docId'];

    _nameController..text = updateClientData['name'];
    _phoneController..text = updateClientData['phone'];
    _emailController..text = updateClientData['email'];
    _gstController..text = updateClientData['GST'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: customAppBar(context, "Update Client Details"),
      body: Builder(builder: (BuildContext context) {
        return Container(
          color: Colors.white54,
          child: ListView(
            padding: EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              Form(
                  key: _clientFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height / 15, 0, 0),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            textCapitalization: TextCapitalization.words,
                            keyboardType: TextInputType.name,
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(
                                Icons.business_outlined,
                                color: Colors.black,
                              ),
                            ),
                            validator: (String value) {
                              if (value.isEmpty)
                                return 'Please enter some text';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: Colors.black,
                              ),
                            ),
                            validator: (String value) {
                              String patttern = r'(^(?:[+0]9)?[0-9]{10}$)';
                              RegExp regExp = new RegExp(patttern);
                              if (value.length == 0) {
                                return 'Please enter mobile number';
                              } else if (!regExp.hasMatch(value)) {
                                return 'Please enter valid mobile number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.black,
                              ),
                            ),
                            validator: (String value) {
                              if (value.isEmpty)
                                return 'Please enter some text';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            controller: _gstController,
                            decoration: InputDecoration(
                              labelText: 'GST Number',
                              prefixIcon: Icon(
                                Icons.business_center_outlined,
                                color: Colors.black,
                              ),
                            ),
                            validator: (String value) {
                              if (value.isEmpty)
                                return 'Please enter some text';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                              padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                              alignment: Alignment.center,
                              child: !updatingClientInProgress
                                  ? MaterialButton(
                                      color: Colors.blue[800],
                                      child: Text(
                                        "Update Client",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20),
                                      ),
                                      height: 50,
                                      minWidth: double.infinity,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      onPressed: () async {
                                        HapticFeedback.lightImpact();

                                        if (_clientFormKey.currentState
                                            .validate()) {
                                          setState(() {
                                            updatingClientInProgress = true;
                                          });
                                          await _updateClientFn()
                                              .then((clientCreation) {
                                            if (clientCreation) {
                                              setState(() {
                                                updatingClientInProgress =
                                                    false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Colors.blue[800],
                                                      content: Text(
                                                        "Client ${_nameController.text.trim()} updated successfully",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )));
                                              Navigator.pop(context);
                                              resetAllValues();
                                            } else {
                                              setState(() {
                                                updatingClientInProgress =
                                                    false;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Colors.amber,
                                                      content: Text(
                                                        "Error!! Please try again after some time",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      )));
                                            }
                                          });
                                        }
                                      },
                                    )
                                  : CircularProgressIndicator.adaptive(
                                      valueColor: animationController.drive(
                                          ColorTween(
                                              begin: Colors.blue[800],
                                              end: Colors.green[300])))),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      }),
    ));
  }

  void resetAllValues() {
    _clientFormKey.currentState.reset();
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _gstController.clear();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<bool> _updateClientFn() async {
    DocumentReference documentReference =
        dbCollection.collection(clientId).doc("ClientsDocument");

    bool success = await documentReference
        .collection("ClientsCollection")
        .doc(updateClientId)
        .set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          "email": _emailController.text.trim(),
          "GST": _gstController.text.trim()
        })
        .timeout(Duration(seconds: 4), onTimeout: () => false)
        .then((value) {
          return true;
        });

    return success;
  }
}
