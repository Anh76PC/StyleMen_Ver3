import 'package:flutter/material.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.red,
  Color textColor = Colors.white,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: textColor, fontSize: 16)),
      backgroundColor: backgroundColor.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: EdgeInsets.only(top: kToolbarHeight + 24, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
