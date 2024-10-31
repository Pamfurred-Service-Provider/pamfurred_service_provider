import 'dart:io'; // Required to use File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/screens/edit_profile.dart';
import 'package:service_provider/screens/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? image;
  final ImagePicker picker = ImagePicker();
  Map<String, dynamic> profileData = {};
  // Method to pick an image from the gallery
  Future<void> changeImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image =
            File(pickedFile.path); // Update the state with the selected image
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profileData: profileData),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        profileData = result;
        debugPrint('Updated profile data: $profileData'); // Debug statement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(),
                ), // Spacer to push content to the right
                Text(
                  profileData['establishment name'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(160, 62, 6, 1),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.logout, size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(150.0),
                      child: image == null
                          ? Image.asset(
                              'assets/Image_null.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.fill,
                            )
                          : Image.file(
                              image!, // Display the picked image
                              width: 200,
                              height: 200,
                              fit: BoxFit.fill,
                            ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: ElevatedButton(
                        onPressed:
                            changeImage, // Call the changeImage method to pick an image
                        child: const Row(
                          children: [
                            Icon(Icons.camera_alt_rounded, size: 16),
                            SizedBox(width: 5),
                            Text("Edit Photo"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  indent: 16.0,
                  endIndent: 16.0,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Details:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: _navigateToEditProfile,
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 5),
                            Text("Edit Details"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Opening Time: ${profileData['time open'] ?? ''}"),
                      const SizedBox(height: 10),
                      Text("Closing Time: ${profileData['time close'] ?? ''}"),
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text(
                        "Pets Catered:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text("Pets to Cater:"),
                      if (profileData['petsList'] != null &&
                          profileData['petsList'] is List<String> &&
                          profileData['petsList'].isNotEmpty)
                        ...profileData['petsList']
                            .map<Widget>((pet) => Text(pet.toString()))
                            .toList()
                      else
                        const Text("No pets specified"),
                      const SizedBox(height: 10),
                      Text(
                          "Number of Pets Catered per day: ${profileData['number of pets'] ?? ''}"),
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text(
                        "Business Address:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                          "Full Address: ${profileData['exact address'] ?? ''}"),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
