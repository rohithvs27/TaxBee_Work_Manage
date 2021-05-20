import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:new_ca_management_app/widgets/customappbar.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseAuthException authException;
FirebaseFirestore dbCollection = FirebaseFirestore.instance;
String clientId;
String tempPassword = "password";
AnimationController animationController;

/// Entrypoint example for various sign-in flows with Firebase.
class CreateNewEmp extends StatefulWidget {
  final String clientId;
  CreateNewEmp(this.clientId);

  @override
  State<StatefulWidget> createState() => _CreateNewEmpState();
}

class _CreateNewEmpState extends State<CreateNewEmp>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
    clientId = widget.clientId;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: customAppBar(context, "Add Employee"),
      body: Builder(builder: (BuildContext context) {
        return Container(
          color: Colors.white54,
          child: ListView(
            padding: EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              _EmailPasswordForm(),
            ],
          ),
        );
      }),
    ));
  }
}

class _EmailPasswordForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  bool _isAdmin = false;
  bool creatingUserInProgress = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              0, MediaQuery.of(context).size.height / 15, 0, 0),
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.black,
                      ),
                    ),
                    validator: (String value) {
                      bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value);
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      if (!emailValid) return 'Please enter valid email ID';
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Colors.black,
                      ),
                    ),
                    validator: (String value) {
                      if (value.isEmpty) return 'Please enter some text';
                      return null;
                    },
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: Center(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              "Make as Admin User",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          Expanded(
                            child: Switch(
                              value: _isAdmin,
                              onChanged: (value) {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _isAdmin = !_isAdmin;
                                });
                              },
                              inactiveThumbColor: Colors.grey,
                              activeColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    alignment: Alignment.center,
                    child: !creatingUserInProgress
                        ? MaterialButton(
                            color: Colors.blue[800],
                            child: Text(
                              "Create User",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20),
                            ),
                            height: 50,
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            onPressed: () async {
                              setState(() {
                                creatingUserInProgress = true;
                              });
                              HapticFeedback.lightImpact();
                              if (_formKey.currentState.validate()) {
                                _createNewNonAdminUser();
                              }
                            },
                          )
                        : CircularProgressIndicator.adaptive(
                            valueColor: animationController.drive(ColorTween(
                                begin: Colors.blue[800],
                                end: Colors.green[300]))),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createNewNonAdminUser() async {
    try {
      final User user = (await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: tempPassword,
      ))
          .user;

      /*dbCollection
          .collection("UsersCompanyMatchCollection")
          .doc(user.uid)
          .set({"companyId": clientId, "name": _nameController.text.trim()});*/

      DocumentReference documentReference =
          dbCollection.collection(clientId).doc("UserDocument");

      documentReference.collection("UserCollection").doc(user.uid).set({
        'name': _nameController.text.trim(),
        'isAdmin': _isAdmin,
        "email": _emailController.text.trim()
      }).then((value) {
        setState(() {
          creatingUserInProgress = false;
        });
        resetPassword(
            _nameController.text.trim(), _emailController.text.trim());

        _formKey.currentState.reset();
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();

        /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.amber,
          content: Text(
            "New User Added. Password reset link sent",
            style: TextStyle(color: Colors.black),
          ),
        ));
        Navigator.pop(context);*/
      });
    } catch (e) {
      authException = e;
      setState(() {
        creatingUserInProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          authException.message,
          style: TextStyle(color: Colors.white),
        ),
      ));
    }
  }

  Future<void> resetPassword(String name, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.blue[800],
          content: Text(
            "$name added. Password reset link sent to $email",
            style: TextStyle(color: Colors.white),
          ),
        ));
      });
    } catch (e) {
      authException = e;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          authException.message,
          style: TextStyle(color: Colors.white),
        ),
      ));
    }
  }

  // Example code of how to sign in with email and password.

}
