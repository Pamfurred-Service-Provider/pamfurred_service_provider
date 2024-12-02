import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';

class CustomWideButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final bool Function()? validator; // Optional validation function
  final Function()? onValidationFailed; // Optional failure handler
  final bool isOutlineButton; // For outline button style
  final bool isLoading; // New parameter to show loading indicator

  const CustomWideButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.validator,
    this.onValidationFailed,
    this.isOutlineButton = false, // Default to filled button if not specified
    this.isLoading = false, // Default to not loading
  });

  static const Color _defaultBackgroundColor = primaryColor;
  static const double _defaultBorderRadius = secondaryBorderRadius;
  static const TextStyle _defaultTextStyle = TextStyle(
    color: Colors.white,
    fontSize: regularText,
    fontWeight: FontWeight.normal,
  );
  static const TextStyle _outlineTextStyle = TextStyle(
    color: primaryColor, // Text color for outline button
    fontSize: regularText,
    fontWeight: FontWeight.normal,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ensure button takes up the full width
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_defaultBorderRadius),
            ),
          ),
          backgroundColor: WidgetStateProperty.all<Color>(
            isOutlineButton
                ? Colors.transparent
                : _defaultBackgroundColor, // Transparent for outline
          ),
          side: isOutlineButton
              ? WidgetStateProperty.all(const BorderSide(
                  color: primaryColor)) // Outline with primary color border
              : null, // No border for filled button
        ),
        onPressed: isLoading
            ? null
            : () {
                // Perform validation if a validator is provided
                if (validator != null) {
                  if (validator!()) {
                    onPressed?.call();
                  } else {
                    // Call the custom failure handler if provided
                    if (onValidationFailed != null) {
                      onValidationFailed!();
                    }
                  }
                } else {
                  onPressed
                      ?.call(); // Execute directly if no validation is needed
                }
              },
        child: Padding(
          padding: const EdgeInsets.all(tertiarySizedBox),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: isOutlineButton
                      ? _outlineTextStyle
                      : _defaultTextStyle, // Text style for outline or filled button
                ),
        ),
      ),
    );
  }
}
