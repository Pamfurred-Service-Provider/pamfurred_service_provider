import 'dart:io'; // Required to use File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/screens/edit_profile.dart';
import 'package:service_provider/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? image;
  final ImagePicker picker = ImagePicker();
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;

      if (userSession == null) {
        throw Exception("User not logged in");
      }

      // Get user ID from session
      final userId = userSession.user.id;

      print('User ID: $userId');

      // Fetch the user data
      final response = await Supabase.instance.client
          .from('service_provider')
          .select(
            'name, image, category,'
            'time_open, time_close, pets_catered, latitude, longitude,'
            'sentiment_label, approval_status, number_of_pets',
          )
          .eq('user_id', userId)
          .single(); // This will throw an error if multiple rows are found

      print('response: $response');
      // Handle the data correctly
      if (response != null) {
        setState(() {
          profileData =
              response as Map<String, dynamic>; // Access the data directly
          isLoading = false;
        });
      } else {
        throw Exception("Error fetching user data: ${response.error.message}");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false; // Stop loading even on error
      });
      // Show a snackbar on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user data')),
        );
      }
    }
  }

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
        print('Updated profile data: $profileData');
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
                    child: Container()), // Spacer to push content to the right
                Text(
                  profileData?['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(160, 62, 6, 1),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.logout, size: 30),
                      onPressed: () {
                        Supabase.instance.client.auth.signOut().then((_) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        });
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
                          ? (profileData?['image'] != null &&
                                  profileData!['image'].isNotEmpty
                              ? Image.network(
                                  profileData!['image'],
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.fill,
                                )
                              : Image.asset(
                                  'assets/Image_null.png',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.fill,
                                ))
                          : Image.file(
                              image!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.fill,
                            ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: ElevatedButton(
                        onPressed: changeImage,
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
                const Divider(indent: 16.0, endIndent: 16.0),
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
                      _buildDetailRow(
                          "Opening Time:", profileData?['time_open']),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                          "Closing Time:", profileData?['time_close']),
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text(
                        "Pets Catered:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      if (profileData?['pets_catered'] != null)
                        if (profileData!['pets_catered'] is List)
                          Text(
                            profileData!['pets_catered']
                                .map((pet) => pet.toString())
                                .join(', '), // Join pets with commas
                            style: const TextStyle(
                                fontSize: 16), // Optional styling
                          )
                        else if (profileData?['pets_catered'] is Map)
                          Text(
                            profileData!['pets_catered']
                                .entries
                                .map((entry) => '${entry.key}: ${entry.value}')
                                .join(', '), // Join entries with commas
                            style: const TextStyle(
                                fontSize: 16), // Optional styling
                          )
                        else
                          const Text("No pets specified"),
                      const SizedBox(height: 10),
                      _buildDetailRow("Number of Pets Catered per day:",
                          profileData?['number_of_pets']?.toString() ?? ''),
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text(
                        "Business Address:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                        "Location:",
                        "Latitude: ${profileData?['latitude'] ?? ''}, "
                            "Longitude: ${profileData?['longitude'] ?? ''}",
                      ),
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

  Widget _buildDetailRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value ?? 'N/A', // Default to 'N/A' if value is null
          style: const TextStyle(
              fontSize: 16,
              color: Colors.black54), // Different style for values
        ),
      ],
    );
  }
}
