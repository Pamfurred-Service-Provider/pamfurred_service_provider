import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/header.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/providers/register_provider.dart';
import 'package:service_provider/screens/Register/address_info.dart';
import 'package:service_provider/screens/register/intro_to_app.dart';

class PhoneNumberScreen extends ConsumerStatefulWidget {
  final Map<String, TextEditingController> controllers;

  const PhoneNumberScreen({super.key, required this.controllers});

  @override
  PhoneNumberScreenState createState() => PhoneNumberScreenState();
}

class PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  bool _showError = false;

  /// Validates if the phone number contains exactly 10 digits, including the country code
  bool _validatePhoneNumber() {
    final phoneNumber = widget.controllers['phoneNumber']?.text.trim() ?? '';
    ref.read(phoneNumberProvider.notifier).state = phoneNumber;

    // Remove all non-numeric characters (this includes spaces and symbols)
    final phoneDigits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Check if the phone number has at least the country code (assuming country code + area code + number)
    // We expect 10 digits for the phone number excluding the country code (length may vary depending on country)
    return phoneDigits.isNotEmpty && phoneDigits.length >= 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader("Phone number"),
            const SizedBox(height: secondarySizedBox),
            formDescription(context,
                "Please provide your phone number so that service providers can contact you directly for any updates or important information related to your appointment."),
            const SizedBox(height: tertiarySizedBox),
            RichText(
              text: const TextSpan(
                text: "Phone number ",
                style: TextStyle(color: Colors.black, fontSize: regularText),
                children: [
                  TextSpan(text: "*", style: TextStyle(color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: primarySizedBox),
            SizedBox(
              height: 65,
              child: IntlPhoneField(
                cursorColor: Colors.black,
                initialCountryCode:
                    'PH', // Adjust the country code based on your app's requirements
                invalidNumberMessage: null,
                autovalidateMode: AutovalidateMode.disabled,
                onChanged: (phone) {
                  widget.controllers['phoneNumber']?.text =
                      phone.completeNumber;
                  setState(() {
                    // Trigger state update when phone number changes
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(secondaryBorderRadius),
                  ),
                ),
              ),
            ),
            if (_showError) ...[
              const SizedBox(height: 8.0),
              const Text(
                "Please enter a valid phone number.",
                style: TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: secondarySizedBox),
            CustomWideButton(
              text: "Next",
              onPressed: () {
                // Validate using the custom validator
                if (_validatePhoneNumber()) {
                  setState(() {
                    _showError = false;
                  });
                  Navigator.push(
                      context,
                      rightToLeftRoute(
                        AddressDetailsScreen(controllers: {
                          'floorUnitRoom': TextEditingController(),
                          'street': TextEditingController(),
                          'barangay': TextEditingController(),
                          'city': TextEditingController(),
                        }),
                      ));
                } else {
                  setState(() {
                    _showError = true;
                  });
                }
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
