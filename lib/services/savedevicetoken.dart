import 'package:firebase_messaging/firebase_messaging.dart';

Future<String> saveDeviceToken() async {
  final fbm = FirebaseMessaging();
  return await fbm.getToken();
}
