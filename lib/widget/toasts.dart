import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toasts {
  static final Toasts _instance = Toasts._internal();

  Toasts._internal();

  late FToast _fToast;

  static initialize(BuildContext context) {
    _instance._initializeInternal(context);
  }

  _initializeInternal(BuildContext context) {
    _fToast = FToast();
    _fToast.init(context);
  }

  _showToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg,
              style: TextStyle(
                color: Colors.white,
              )),
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  static toast(String message) {
    _instance._showToast(message);
  }
}
