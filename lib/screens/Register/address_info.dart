import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/header.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/screens/Register/credentials.dart';
import 'package:service_provider/screens/pin_location.dart';
import 'package:service_provider/screens/register/intro_to_app.dart';

class AddressDetailsScreen extends StatefulWidget {
  final Map<String, TextEditingController> controllers;

  const AddressDetailsScreen({super.key, required this.controllers});

  @override
  AddressDetailsScreenState createState() => AddressDetailsScreenState();
}

class AddressDetailsScreenState extends State<AddressDetailsScreen> {
  bool _showError = false;

  // Variables for selected location
  double? pinnedLatitude;
  double? pinnedLongitude;
  String? pinnedAddress;

  bool _validateFields() {
    final street = widget.controllers['street']?.text.trim() ?? '';
    final barangay = widget.controllers['barangay']?.text.trim() ?? '';
    final city = widget.controllers['city']?.text.trim() ?? '';

    return pinnedLatitude != null &&
        pinnedLongitude != null &&
        pinnedAddress != null &&
        street.isNotEmpty &&
        barangay.isNotEmpty &&
        city.isNotEmpty;
  }

  // Open PinLocationNew screen to allow the user to select a location
  Future<void> _navigateToPinLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PinLocationNew()),
    );

    if (result != null) {
      setState(() {
        pinnedLatitude = result['latitude'];
        pinnedLongitude = result['longitude'];
        pinnedAddress = result['address'];

        // Log to verify the data received from PinLocationNew screen
        print('Result from PinLocationNew: $result');

        // Split the address into components
        List<String> addressParts = pinnedAddress!.split(', ');

        // Extract street, barangay, and city
        String street = addressParts.isNotEmpty ? addressParts[0] : '';
        String barangay = addressParts.length > 1 ? addressParts[1] : '';
        String city = addressParts.length > 2 ? addressParts[2] : '';
        // Pre-fill address fields with the extracted components
        widget.controllers['street']?.text = street;
        widget.controllers['barangay']?.text = barangay;
        widget.controllers['city']?.text = city;
      });
    } else {
      // Handle case when no result is returned from PinLocationNew
      print('No location selected');
    }
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
            buildSectionHeader("Establishment Address"),
            const SizedBox(height: secondarySizedBox),
            formDescription(context,
                "Please pin your establishment address, as this will be used by pet owners to locate you for your services."),
            const SizedBox(height: tertiarySizedBox),
            RichText(
              text: const TextSpan(
                text: "Pin Location ",
                style: TextStyle(color: Colors.black, fontSize: regularText),
                children: [
                  TextSpan(text: "*", style: TextStyle(color: primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: primarySizedBox),
            // Button to open the map and pin location
            CustomWideButton(
              text: "Pin Location",
              onPressed: _navigateToPinLocation,
            ),
            const SizedBox(height: tertiarySizedBox),

            // Show the pinned location address or a message if not yet pinned
            if (pinnedLatitude != null && pinnedLongitude != null)
              Text(
                'Pinned Location: $pinnedAddress',
                style: TextStyle(fontSize: regularText),
              )
            else
              Text(
                "No location pinned yet.",
                style: TextStyle(color: Colors.red, fontSize: regularText),
              ),

            const SizedBox(height: tertiarySizedBox),

            // Show error message if validation fails (e.g., no location pinned)
            if (_showError)
              Text(
                "Please pin your location before proceeding.",
                style: TextStyle(color: Colors.red, fontSize: regularText),
              ),

            // Next button that validates fields before proceeding
            CustomWideButton(
              text: "Next",
              onPressed: () {
                if (_validateFields()) {
                  setState(() => _showError = false);

                  // Proceed to the next screen
                  Navigator.push(
                    context,
                    rightToLeftRoute(CredentialsScreen(controllers: {
                      'email': TextEditingController(),
                      'password': TextEditingController(),
                    })),
                  );
                } else {
                  setState(() => _showError = true);
                }
              },
            ),
            const SizedBox(height: quaternarySizedBox),
            hasAnAccount(context),
          ],
        ),
      ),
    );
  }
}
