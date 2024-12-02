import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/header.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/components/text_field.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/providers/register_provider.dart';
import 'package:service_provider/screens/register/intro_to_app.dart';
import 'package:service_provider/screens/register/phone_number.dart';

class PersonalInformationScreen extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;

  const PersonalInformationScreen({super.key, required this.controllers});

  @override
  PersonalInformationScreenState createState() =>
      PersonalInformationScreenState();
}

class PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    bool validateFields() {
      final establishmentName =
          widget.controllers['establishmentName']?.text.trim() ?? '';
      ref.read(nameProvider.notifier).state = establishmentName;
      return establishmentName.isNotEmpty;
    }

    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader("Business Information"),
            const SizedBox(height: secondaryBorderRadius),
            formDescription(context,
                "Please enter your establishment's name to help us personalize your experience."),
            const SizedBox(height: tertiarySizedBox),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                      label: "Establishment name",
                      controllerKey: "establishmentName", // This key
                      controllers: widget.controllers),
                ),
              ],
            ),
            if (_showError) ...[
              const SizedBox(height: 8.0),
              const Text(
                "Please fill out all required fields.",
                style: TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: tertiarySizedBox),
            CustomWideButton(
              text: "Next",
              validator: validateFields,
              onValidationFailed: () {
                setState(() {
                  _showError = true;
                });
              },
              onPressed: () {
                setState(() {
                  _showError = false;
                });
                Navigator.push(
                    context,
                    rightToLeftRoute(PhoneNumberScreen(controllers: {
                      'phoneNumber': TextEditingController(),
                    })));
              },
            ),
            const SizedBox(height: quaternarySizedBox),
            hasAnAccount(context)
          ],
        ),
      ),
    );
  }
}
