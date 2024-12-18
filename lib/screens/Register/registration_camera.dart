import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/components/header.dart';
import 'package:service_provider/providers/register_provider.dart';
import 'package:service_provider/screens/Register/intro_to_app.dart';
import 'package:service_provider/screens/otp_input.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/components/custom_appbar.dart';

class RegistrationCameraScreen extends ConsumerStatefulWidget {
  final Map<String, TextEditingController>
      controllers; // Passed from previous screens

  const RegistrationCameraScreen(
      {Key? key,
      required this.controllers,
      required Null Function(dynamic imageUrl) onImageUploaded})
      : super(key: key);

  @override
  ConsumerState<RegistrationCameraScreen> createState() =>
      _RegistrationCameraScreenState();
}

class _RegistrationCameraScreenState
    extends ConsumerState<RegistrationCameraScreen> {
  final supabase = Supabase.instance.client;
  File? imageFile;
  bool isUploading = false;
  bool isLoading = false;
  bool _showError = false;

  /// Capture an image using the camera
  Future<void> captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _showError = false;
      });
    }
  }

  /// Upload image to Supabase Storage
  Future<String?> uploadImage() async {
    try {
      setState(() => isUploading = true);
      final filePath =
          'business_permit/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await supabase.storage
          .from('service_provider_images')
          .upload(filePath, imageFile!);

      if (response.isNotEmpty) {
        final imageUrl = supabase.storage
            .from('service_provider_images')
            .getPublicUrl(filePath);
        return imageUrl;
      } else {
        throw Exception("Image upload failed");
      }
    } catch (e) {
      _showErrorDialog("Error uploading image: $e");
      return null;
    } finally {
      setState(() => isUploading = false);
    }
  }

  /// Register user with image URL
  Future<void> registerUser() async {
    setState(() => isLoading = true);

    try {
      final establishmentName = ref.watch(nameProvider);
      final email = ref.watch(emailProvider);
      final phoneNumber = ref.watch(phoneNumberProvider);
      final password = ref.watch(passwordProvider);
      final floorUnitRoom = ref.watch(floorUnitRoomProvider);
      final street = ref.watch(streetProvider);
      final barangay = ref.watch(barangayProvider);
      final city = ref.watch(cityProvider);

      final pinnedLatitude = ref.watch(pinnedLatitudeProvider);
      final pinnedLongitude = ref.watch(pinnedLongitudeProvider);

      final imageUrl = await uploadImage();

      if (imageUrl == null) return;

      // Register the user with Supabase
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'phone_number': phoneNumber,
        },
      );

      if (response.user != null) {
        final userId = response.user!.id;

        // Insert address information
        final addressResponse = await supabase
            .from('address')
            .insert({
              'floor_unit_room': floorUnitRoom,
              'street': street,
              'barangay': barangay,
              'city': city,
              'latitude': pinnedLatitude,
              'longitude': pinnedLongitude,
            })
            .select('address_id')
            .single();

        final addressId = addressResponse['address_id'];

        // Insert data into 'user' table
        await supabase.from('user').insert({
          'user_id': userId,
          'phone_number': phoneNumber,
          'email': email,
          'user_type': 'service_provider',
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'address_id': addressId,
        });

        // Insert data into 'service_provider' table
        await supabase.from('service_provider').insert({
          'name': establishmentName,
          'sp_id': userId,
          'sp_business_permit': imageUrl,
        });

        // Navigate to OTP verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog("Error during registration: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionHeader("Capture Business Permit"),
              const SizedBox(height: secondaryBorderRadius),
              formDescription(
                context,
                "Capture a clear image of your business permit. This will be uploaded and stored for your service registration.",
              ),
              const SizedBox(height: tertiarySizedBox),
              if (imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    imageFile!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: secondarySizedBox),
              CustomWideButton(
                text: "Capture Image",
                onPressed: captureImage,
              ),
              const SizedBox(height: secondarySizedBox),
              if (_showError)
                Text(
                  "Please capture your business permit before proceeding.",
                  style: const TextStyle(color: Colors.red),
                ),
              CustomWideButton(
                text: "Register",
                onPressed: (isUploading || isLoading)
                    ? null
                    : () {
                        if (imageFile == null) {
                          setState(() => _showError = true);
                        } else {
                          registerUser();
                        }
                      },
                isLoading: isUploading || isLoading,
              ),
              const SizedBox(height: quaternarySizedBox),
              hasAnAccount(context),
            ],
          ),
        ),
      ),
    );
  }
}
