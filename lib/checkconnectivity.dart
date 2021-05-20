import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckInternetConnectivityProvider extends ChangeNotifier {
  Connectivity _connectivity = new Connectivity();

  bool _isonline;

  bool get isOnline => _isonline;

  startMonitoring() async {
    await initConnectivity();
    _connectivity.onConnectivityChanged.listen((result) async {
      if (result == ConnectivityResult.none) {
        _isonline = false;
        notifyListeners();
      } else {
        await updateConnectionStatus().then((bool isConnected) {
          if (isConnected) {
            _isonline = true;
            notifyListeners();
          } else {
            _isonline = false;
            notifyListeners();
          }
        });
      }
    });
  }

  initConnectivity() async {
    try {
      var status = await _connectivity.checkConnectivity();
      if (status == ConnectivityResult.none) {
        _isonline = false;
      } else {
        _isonline = true;
        notifyListeners();
      }
    } on PlatformException catch (e) {
      print("PlatformException:" + e.toString());
    }
  }

  Future<bool> updateConnectionStatus() async {
    bool isConnected;
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } on SocketException catch (_) {
      isConnected = false;
    }
    return isConnected;
  }
}
