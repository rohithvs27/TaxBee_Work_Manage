import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_ca_management_app/checkconnectivity.dart';
import 'package:new_ca_management_app/widgets/loadingscreen.dart';
import 'package:provider/provider.dart';
import 'services/newuserregistration.dart';
import 'services/usersignin.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseAuthException authException;
TextStyle snackBarTextStyle = TextStyle(
  color: Colors.white,
);

/// Entrypoint example for various sign-in flows with Firebase.
class SignInPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  AnimationController animationController;
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
    Provider.of<CheckInternetConnectivityProvider>(context, listen: false)
        .startMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckInternetConnectivityProvider>(
      builder: (context, checkConnection, child) {
        return SafeArea(child: Scaffold(
          body: Builder(builder: (BuildContext context) {
            return Container(
              color: Colors.white24,
              child: ListView(
                padding: EdgeInsets.all(8),
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  _EmailPasswordForm(animationController),
                ],
              ),
            );
          }),
        ));
      },
    );
  }
}

class _EmailPasswordForm extends StatefulWidget {
  final animationController;

  _EmailPasswordForm(this.animationController);
  @override
  State<StatefulWidget> createState() => _EmailPasswordFormState();
}

bool isLoading = false;

class _EmailPasswordFormState extends State<_EmailPasswordForm> {
  bool _newRegistration = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _resetformKey = GlobalKey<FormState>();

  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Consumer<CheckInternetConnectivityProvider>(
        builder: (context, checkConnection, child) {
      return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: height / 20,
                ),
                Container(
                  alignment: Alignment.center,
                  child: FittedBox(
                      child: Image.asset(
                    "assets/images/taxbee_logo.png",
                    semanticLabel: "TaxBee WMA",
                    fit: BoxFit.cover,
                    height: height / 6,
                    width: width / 2,
                  )),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _companyIdController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    prefixIcon: Icon(
                      Icons.build_outlined,
                      color: Colors.black,
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
                _newRegistration
                    ? TextFormField(
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'User Name',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.black,
                          ),
                        ),
                        validator: (String value) {
                          if (value.isEmpty) return 'Please enter some text';

                          return null;
                        },
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                _newRegistration
                    ? SizedBox(
                        height: 10,
                      )
                    : Container(
                        height: 0,
                        width: 0,
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
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Icons.lock_outlined,
                      color: Colors.black,
                    ),
                  ),
                  validator: (String value) {
                    if (value.isEmpty) return 'Please enter some text';
                    return null;
                  },
                  obscureText: true,
                ),
                SizedBox(
                  height: 10,
                ),
                _newRegistration
                    ? TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: Colors.black,
                          ),
                        ),
                        validator: (String value) {
                          if (value.isEmpty) return 'Please enter some text';
                          if (value != _passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                        obscureText: true,
                      )
                    : Container(
                        height: 0,
                        width: 0,
                      ),
                SizedBox(
                  height: 10,
                ),
                !_newRegistration
                    ? Center(
                        child: TextButton(
                            child: Text(
                              "Forgot /Reset Password",
                              style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        content: resetpasswordalert(),
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              "Reset",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onPressed: () {
                                              if (_resetformKey.currentState
                                                  .validate()) {
                                                resetPassword(_emailController
                                                    .text
                                                    .trim());
                                              }
                                            },
                                          )
                                        ],
                                      ));
                            }),
                      )
                    : Container(height: 0, width: 0),
                Center(
                    child: TextButton(
                        child: !_newRegistration
                            ? RichText(
                                text: TextSpan(
                                    text: "Register",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black)))
                            : RichText(
                                text: TextSpan(
                                    text: "Sign In",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black))),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _newRegistration = !_newRegistration;
                          });
                        })),
                !_newRegistration
                    ? Container(
                        padding: const EdgeInsets.only(top: 16.0),
                        alignment: Alignment.center,
                        child: !isLoading
                            ? MaterialButton(
                                color: Colors.blue[800],
                                child: Text(
                                  "Sign In",
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
                                  HapticFeedback.lightImpact();
                                  if (_formKey.currentState.validate()) {
                                    loadingScreen(context);
                                    if (checkConnection.isOnline != null) {
                                      userSignin(
                                          _companyIdController.text
                                              .toLowerCase()
                                              .replaceAll(" ", "")
                                              .trim(),
                                          _emailController.text.trim(),
                                          _passwordController.text.trim(),
                                          context);
                                    } else {
                                      return Center(
                                        child:
                                            CircularProgressIndicator.adaptive(
                                                valueColor: widget
                                                    .animationController
                                                    .drive(ColorTween(
                                                        begin: Colors.blue[800],
                                                        end: Colors
                                                            .green[300]))),
                                      );
                                    }
                                  }
                                },
                              )
                            : CircularProgressIndicator.adaptive(
                                valueColor: widget.animationController.drive(
                                    ColorTween(
                                        begin: Colors.blue[800],
                                        end: Colors.green[300]))))
                    : Container(
                        padding: const EdgeInsets.only(top: 16.0),
                        alignment: Alignment.center,
                        child: !isLoading
                            ? MaterialButton(
                                color: Colors.blue[800],
                                child: Text(
                                  "Register",
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
                                  loadingScreen(context);
                                  HapticFeedback.lightImpact();
                                  if (_formKey.currentState.validate()) {
                                    createNewClient(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                        _nameController.text.trim(),
                                        _companyIdController.text
                                            .toLowerCase()
                                            .replaceAll(" ", "")
                                            .trim(),
                                        context);
                                  }
                                },
                              )
                            : CircularProgressIndicator.adaptive(
                                valueColor: widget.animationController.drive(
                                    ColorTween(
                                        begin: Colors.blue[800],
                                        end: Colors.green[300]))),
                      ),
              ],
            ),
          ));
    });
  }

  @override
  void dispose() {
    widget.animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyIdController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget resetpasswordalert() {
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
                "Reset Password",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Form(
                key: _resetformKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Reset password',
                        prefixIcon:
                            Icon(Icons.email_outlined, color: Colors.black),
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

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Please check you email for password reset link",
          style: snackBarTextStyle,
        ),
      ));
      Navigator.pop(context);
    } catch (e) {
      authException = e;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          authException.message,
          style: snackBarTextStyle,
        ),
      ));
    }
  }
}
