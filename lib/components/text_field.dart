import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:service_provider/components/capitalize_first_letter.dart';
import 'package:service_provider/components/globals.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String controllerKey;
  final Map<String, TextEditingController> controllers;
  final bool isEmail;
  final bool isRequired;
  final String? defaultValue; // Optional default value

  const CustomTextField({
    super.key,
    required this.label,
    required this.controllerKey,
    required this.controllers,
    this.isEmail = false,
    this.isRequired =
        true, // Default is true, making the field required by default
    this.defaultValue, // Default value is optional
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);

    // If a defaultValue is provided, set it in the controller
    if (widget.defaultValue != null) {
      widget.controllers[widget.controllerKey]?.text = widget.defaultValue!;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _errorMessage =
            null; // Clear the error message when the field is focused
      });
    }
  }

  String? _validateInput(String? value) {
    // Check if the field is required and if the value is empty
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return "${widget.label} is required";
    }
    // Validate email if the field is marked as email
    if (widget.isEmail &&
        value != null &&
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: "${widget.label} ",
            style: const TextStyle(color: Colors.black, fontSize: regularText),
            children: [
              if (widget.isRequired) // Show asterisk only if required
                const TextSpan(
                    text: "*", style: TextStyle(color: primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: secondarySizedBox),
        TextFormField(
          controller: widget.controllers[widget.controllerKey],
          focusNode: _focusNode,
          obscureText: false,
          keyboardType:
              widget.isEmail ? TextInputType.emailAddress : TextInputType.text,
          textCapitalization: widget.isEmail
              ? TextCapitalization.none
              : TextCapitalization.sentences,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(secondaryBorderRadius),
            ),
            hintText: widget.isEmail ? "Enter your email" : null,
            errorText: _errorMessage,
          ),
          onChanged: (value) {
            setState(() {
              _errorMessage = null; // Hide error when typing
            });
          },
          onFieldSubmitted: (value) {
            setState(() {
              _errorMessage =
                  _validateInput(value); // Show error after submission
            });
          },
          validator: (value) {
            final error = _validateInput(value);
            setState(() {
              _errorMessage = error; // Update error message during validation
            });
            return error;
          },
          inputFormatters: widget.isEmail
              ? []
              : [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final newText = capitalizeFirstLetter(newValue.text);
                    return newValue.copyWith(text: newText);
                  }),
                ],
        ),
      ],
    );
  }
}