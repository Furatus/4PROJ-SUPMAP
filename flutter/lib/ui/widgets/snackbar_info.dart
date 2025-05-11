import 'package:flutter/material.dart';

class SnackbarInfo {
  static void show(BuildContext context, String message, duration,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
