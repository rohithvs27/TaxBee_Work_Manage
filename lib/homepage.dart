import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_ca_management_app/createnewjob.dart';
import 'package:new_ca_management_app/ticketslistpage.dart';
import 'package:flutter/services.dart';

import 'paymentscreen.dart';

var gadmin;
var guid;
var gclientId;
var gempname;
var gemail;
var gtoken;

FirebaseFirestore dbCollection = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  HomePage.withMetaData(clientId, uid, admin, empname, email, token) {
    gclientId = clientId;
    guid = uid;
    gadmin = admin;
    gempname = empname;
    gemail = email;
    gtoken = token;
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController();

  List<Widget> _screens = [
    TicketListPage(gadmin, guid, gclientId, gempname, gemail),
    CreateNewJob(gclientId, gempname),
  ];
  int _selectedIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int _selectedIndex) {
    HapticFeedback.lightImpact();
    _pageController.jumpToPage(_selectedIndex);
  }

  final _formKey = new GlobalKey<FormState>();
  TextEditingController _promoCodeController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
        child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  label: "Home",
                  icon: Icon(Icons.home),
                ),
                BottomNavigationBarItem(
                  label: "New Job",
                  icon: Icon(Icons.add_outlined),
                ),
              ],
              onTap: _onItemTapped,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black,
            ),
            body: Container(
                child: StreamBuilder(
                    stream: getSubscriptionDetails(
                      context,
                      gclientId,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(
                          height: double.maxFinite,
                          width: double.maxFinite,
                          child: Center(
                              child: CircularProgressIndicator.adaptive(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue[800]),
                          )),
                        );
                      }
                      return (snapshot.data["subscriptionExpiryIn"] == 0)
                          ? Container(
                              color: Colors.blue[800],
                              height: double.maxFinite,
                              width: double.maxFinite,
                              child: SingleChildScrollView(
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.always,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: height / 5,
                                        child: Image.asset(
                                          "assets/images/taxbee_logo.png",
                                        ),
                                      ),
                                      Container(
                                        height: height / 2,
                                        width: double.maxFinite,
                                        color: Colors.blue[800],
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 8, 0),
                                          child: Card(
                                            elevation: 10,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 40, 5, 30),
                                                    child: Text(
                                                      "Subscription expired. Please renew",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color:
                                                              Colors.blue[800]),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        40, 0, 40, 40),
                                                    child: MaterialButton(
                                                        elevation: 5,
                                                        color: Colors.blue[800],
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        height: 70,
                                                        minWidth:
                                                            double.maxFinite,
                                                        child: Text(
                                                          "Rs.9999/year",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        onPressed: () async {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          Navigator.push(
                                                              context,
                                                              new MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      PaymentScreen(
                                                                          gclientId)));
                                                        }),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(20, 0, 20, 0),
                                                    child: TextFormField(
                                                      controller:
                                                          _promoCodeController,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            'Coupon Code',
                                                        prefixIcon: Icon(
                                                          Icons.wallet_giftcard,
                                                          //color: Color(0xFF003580),
                                                        ),
                                                        border:
                                                            new OutlineInputBorder(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  25.0),
                                                          borderSide:
                                                              new BorderSide(),
                                                        ),
                                                      ),
                                                      validator:
                                                          (String value) {
                                                        if (value.isEmpty)
                                                          return 'Please enter some text';
                                                        if (value != "ZeKe")
                                                          return 'Invalid Coupon';
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        40, 40, 40, 0),
                                                    child: MaterialButton(
                                                        elevation: 5,
                                                        color: Colors.blue[800],
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        height: 70,
                                                        minWidth:
                                                            double.maxFinite,
                                                        child: Text(
                                                          "Redeem Coupon",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        onPressed: () async {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          if (_formKey
                                                              .currentState
                                                              .validate()) {
                                                            _promoCodeController
                                                                .clear();
                                                            var today =
                                                                DateTime.now();
                                                            var oneYearFromNow =
                                                                today.add(
                                                                    Duration(
                                                                        days:
                                                                            365));
                                                            dbCollection
                                                                .collection(
                                                                    gclientId)
                                                                .doc(
                                                                    "Subscription")
                                                                .update({
                                                              "subscriptionExpiryIn":
                                                                  365,
                                                              "subscriptionStartDate":
                                                                  today,
                                                              "subscriptionEndDate":
                                                                  oneYearFromNow,
                                                            }).then((value) => {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                          duration: Duration(seconds: 4),
                                                                          backgroundColor: Colors.blue[800],
                                                                          content: Text(
                                                                            "Subscription renewed successfully",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ))),
                                                                      dispose(),
                                                                    });
                                                          }
                                                        }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: height / 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : PageView(
                              controller: _pageController,
                              children: _screens,
                              onPageChanged: _onPageChanged,
                            );
                    }))));
  }

  @override
  void dispose() {
    super.dispose();
    _formKey.currentState.reset();
    _promoCodeController.clear();
    _promoCodeController.dispose();
  }

  Stream<DocumentSnapshot> getSubscriptionDetails(
      BuildContext context, String clientId) async* {
    yield* dbCollection.collection(clientId).doc("Subscription").snapshots();
  }
}
