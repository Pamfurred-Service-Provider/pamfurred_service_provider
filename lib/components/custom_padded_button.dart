import 'package:flutter/material.dart';
import 'globals.dart';

Widget customPaddedTextButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(secondaryBorderRadius),
          ),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          primaryColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: regularText,
          ),
        ),
      ));
}
