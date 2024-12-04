import 'package:flutter/material.dart';
import 'globals.dart';

Widget customPaddedTextButton({
  required String text,
  required VoidCallback onPressed,
  Icon? icon, // Optional icon parameter
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
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Ensures the row takes the minimum size
        children: [
          if (icon != null) ...[
            // Only display the icon if it's provided
            icon,
            const SizedBox(width: 8), // Add spacing between icon and text
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: regularText,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget customPaddedOutlinedTextButton({
  required String text,
  required VoidCallback onPressed,
  Widget? leadingIcon, // Optional leading icon
  Widget? trailingIcon, // Optional trailing icon
}) {
  return TextButton(
    onPressed: onPressed,
    style: ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(secondaryBorderRadius),
          side: const BorderSide(color: primaryColor),
        ),
      ),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.all(10.0),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          leadingIcon,
          const SizedBox(width: 8), // Space between icon and text
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: regularText,
            color: primaryColor,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8), // Space between text and icon
          trailingIcon,
        ],
      ],
    ),
  );
}

Widget customFloatingActionButton(
  BuildContext context, {
  required String buttonText,
  required VoidCallback onPressed,
  required ValueKey<bool> key,
  Icon? icon, // Optional icon parameter
}) {
  const double elevatedButtonHeight = 50;

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(secondaryBorderRadius),
      border: Border.all(width: 0.5, color: primaryColor),
      color: primaryColor,
      boxShadow: [
        BoxShadow(
          color:
              Colors.black.withOpacity(0.2), // Shadow color with transparency
          spreadRadius: 2,
          blurRadius: 8, // How blurry the shadow will appear
          offset: const Offset(2, 4), // Shadow position (x, y)
        ),
      ],
    ),
    height: elevatedButtonHeight,
    margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child: TextButton(
      onPressed: onPressed,
      child: Center(
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Ensures the Row takes only the required space
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 8), // Add spacing between icon and text
            ],
            Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: regularText,
                fontWeight: regularWeight,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
