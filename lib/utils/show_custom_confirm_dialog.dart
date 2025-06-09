import 'package:flutter/material.dart';

Future<bool?> showCustomConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
  required Color confirmTextColor,
  required String cancelText,
  required Color cancelTextColor,
  Color backgroundColor = Colors.white,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: backgroundColor,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      content: Text(
        content,
        style: const TextStyle(color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: TextStyle(color: cancelTextColor),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: TextStyle(color: confirmTextColor),
          ),
        ),
        
      ],
    ),
  );
}
