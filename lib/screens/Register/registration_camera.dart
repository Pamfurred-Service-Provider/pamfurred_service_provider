import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/components/header.dart';
import 'package:service_provider/components/text_field.dart';
import 'package:service_provider/screens/register/intro_to_app.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/components/custom_appbar.dart';

class RegistrationCameraScreen extends StatefulWidget {
  final Function(String) onImageUploaded; // Pass back the image URL

  const RegistrationCameraScreen({super.key, required this.onImageUploaded});

  @override
  State<RegistrationCameraScreen> createState() =>
      _RegistrationCameraScreenState();
}

class _RegistrationCameraScreenState extends State<RegistrationCameraScreen> {
  final supabase = Supabase.instance.client;
  File? imageFile;
  bool isUploading = false;
  bool isLoading = false;
  bool _showError = false;

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

  Future<void> uploadImage() async {
    setState(() {
      isUploading = true;
    });

    final filePath =
        'business_permit/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final response = await supabase.storage
        .from('service_provider_images')
        .upload(filePath, imageFile!);

    if (response.isNotEmpty) {
      final imageUrl = supabase.storage
          .from('service_provider_images')
          .getPublicUrl(filePath);
      widget.onImageUploaded(imageUrl);
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context), // Use the custom app bar
      backgroundColor: Colors.white,
      body: Padding(
        padding: primaryPadding, // Consistent padding across screens
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionHeader("Capture Business Permit"),
              const SizedBox(height: secondaryBorderRadius),
              formDescription(context,
                  "Capture a clear image of your business permit. This will be uploaded and stored for your service registration."),
              const SizedBox(height: tertiarySizedBox),
              if (imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    imageFile!,
                    width: double.infinity,
                    // height: 250,
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
                  "Please capture business permit before proceeding.",
                  style: TextStyle(color: Colors.red, fontSize: regularText),
                ),
              CustomWideButton(
                text: "Register",
                onPressed: isUploading
                    ? null
                    : () {
                        if (imageFile == null) {
                          setState(() {
                            _showError = true;
                          });
                        } else {
                          uploadImage();
                        }
                      },
                isLoading: isUploading,
              ),
              const SizedBox(height: quaternarySizedBox),
              hasAnAccount(context), // Link to login screen
            ],
          ),
        ),
      ),
    );
  }
}
