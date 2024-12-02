import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';
import 'package:fancy_password_field/fancy_password_field.dart';

class PasswordTextField extends StatefulWidget {
  final String label;
  final String controllerKey;
  final Map<String, TextEditingController> controllers;

  const PasswordTextField({
    super.key,
    required this.label,
    required this.controllerKey,
    required this.controllers,
  });

  @override
  PasswordTextFieldState createState() => PasswordTextFieldState();
}

class PasswordTextFieldState extends State<PasswordTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
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
            children: const [
              TextSpan(text: "*", style: TextStyle(color: primaryColor)),
            ],
          ),
        ),
        const SizedBox(height: secondarySizedBox),
        FancyPasswordField(
          controller: widget.controllers[widget.controllerKey],
          focusNode: _focusNode,
          validationRules: {
            DigitValidationRule(),
            UppercaseValidationRule(),
            LowercaseValidationRule(),
            SpecialCharacterValidationRule(),
            MinCharactersValidationRule(6),
          },
          validationRuleBuilder: (rules, value) {
            if (value.isEmpty) {
              return const SizedBox.shrink();
            }
            return ListView(
              shrinkWrap: true,
              children: rules
                  .map(
                    (rule) => rule.validate(value)
                        ? Row(
                            children: [
                              const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                rule.name,
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                rule.name,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                  )
                  .toList(),
            );
          },
          decoration: InputDecoration(
              hintText: "Enter your password",
              contentPadding: const EdgeInsets.all(10.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  secondaryBorderRadius,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: secondaryColor),
                  borderRadius: BorderRadius.circular(secondaryBorderRadius))),
        ),
        const SizedBox(height: secondarySizedBox),
      ],
    );
  }
}
