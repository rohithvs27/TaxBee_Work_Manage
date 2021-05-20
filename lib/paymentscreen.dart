import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

FirebaseFirestore dbCollection = FirebaseFirestore.instance;

class PaymentScreen extends StatefulWidget {
  final clientId;
  PaymentScreen(this.clientId);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Razorpay _razorpay;

  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    openCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Razorpay Sample App'),
        ),
        body: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              MaterialButton(onPressed: openCheckout, child: Text('Open'))
            ])),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_RoO3W8lpbl0joK',
      'amount': 999900,
      'timeout': 300,
      'name': 'TaxBee Ventures Private Limited',
      'description': 'Work Manage Subscription',
      'prefill': {'contact': '9025925249', 'email': 'admin@taxbee.in'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId);
    Future.delayed(Duration(seconds: 3)).then((value) {
      var today = DateTime.now();
      var oneYearFromNow = today.add(Duration(days: 365));
      dbCollection.collection(widget.clientId).doc("Subscription").update({
        "subscriptionExpiryIn": 365,
        "subscriptionStartDate": today,
        "subscriptionEndDate": oneYearFromNow,
      }).then((value) => {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 4),
                backgroundColor: Colors.blue[800],
                content: Text(
                  "Subscription renewed successfully",
                  style: TextStyle(color: Colors.white),
                ))),
            Navigator.pop(context)
          });
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "ERROR: " + response.code.toString() + " - " + response.message,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName);
    Future.delayed(Duration(seconds: 3))
        .then((value) => Navigator.pop(context));
  }
}
