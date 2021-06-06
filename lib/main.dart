import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:new_ca_management_app/checkconnectivity.dart';
import 'package:new_ca_management_app/ticketslistpage.dart';
import 'package:provider/provider.dart';
import './signin.dart';
import './homepage.dart';
import 'package:after_layout/after_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => new CheckInternetConnectivityProvider(),
            child: SignInPage(),
          )
        ],
        child: MaterialApp(
          title: "TaxBee Manage",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            canvasColor: Colors.grey[200],
            fontFamily: "GoogleFonts",
            primaryColor: Colors.blue[800],
          ),
          home: Splash(),
        ));
  }
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with AfterLayoutMixin<Splash> {
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.get('uid');
    bool admin = prefs.getBool('admin');
    String empname = prefs.get('empname');
    String clientId = prefs.get('companyId');
    String token = prefs.get('tokenId');
    String email = prefs.get('email');

    if (uid == null) {
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new SignInPage()));
    } else if (!admin) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (context) =>
              new TicketListPage(admin, uid, clientId, empname, email)));
    } else {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (context) => new HomePage.withMetaData(
              clientId, uid, admin, empname, email, token)));
    }
  }

  void afterFirstLayout(BuildContext context) {
    checkFirstSeen();
  }

  @override
  Widget build(BuildContext context) {
    return new SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          child: Image.asset(
            "assets/images/taxbee_logo.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
