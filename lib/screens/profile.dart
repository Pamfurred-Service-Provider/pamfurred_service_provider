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
  bool isLoading = true; // Initialize loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      setState(() {
        isLoading = true; // Set loading to true when fetching data
      });

      final userSession = Supabase.instance.client.auth.currentSession;

      if (userSession == null) {
        throw Exception("User not logged in");
      }

      final spId = userSession.user.id;
      print('Service Provider ID: $spId');

      final serviceProviderResponse = await Supabase.instance.client
          .from('service_provider')
          .select('name, image, time_open, time_close, number_of_pets')
          .eq('sp_id', spId)
          .single();

      print('Service Provider Response: $serviceProviderResponse');

      if (serviceProviderResponse != null) {
        final userResponse = await Supabase.instance.client
            .from('user')
            .select('address_id')
            .eq('user_id', spId)
            .single();

        print('User Response: $userResponse');

        if (userResponse != null && userResponse['address_id'] != null) {
          final addressId = userResponse['address_id'];

          final addressResponse = await Supabase.instance.client
              .from('address')
              .select('floor_unit_room, street, city, barangay')
              .eq('address_id', addressId)
              .single();

          print('Address Response: $addressResponse');

          if (addressResponse != null) {
            setState(() {
              profileData = {
                ...serviceProviderResponse,
                'address': addressResponse,
              };
              isLoading = false; // Set loading to false once data is fetched
            });
          } else {
            throw Exception("Error fetching address data");
          }
        } else {
          throw Exception("Address ID not found for user");
        }
      } else {
        throw Exception("Error fetching service provider data");
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false; // Stop loading even on error
      });
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Failed to load user data')),
      //   );
      // }
    }
  }

  // Method to change the profile picture
  Future<void> changeImage() async {
    setState(() {
      isLoading = true; // Set loading state to true while uploading
    });

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path); // Temporarily update the image
      });

      try {
        final userSession = Supabase.instance.client.auth.currentSession;

        if (userSession == null) {
          throw Exception("User not logged in");
        }

        final bytes = await image!.readAsBytes();
        final fileName =
            'profile_pic/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final response = await Supabase.instance.client.storage
            .from('service_provider_images')
            .uploadBinary(fileName, bytes);

        if (response.error == null) {
          final imageUrl = Supabase.instance.client.storage
              .from('service_provider_images')
              .getPublicUrl(fileName);

          await Supabase.instance.client
              .from('service_provider')
              .update({'image': imageUrl}).eq('sp_id', userSession.user.id);

          setState(() {
            profileData?['image'] = imageUrl; // Update state with new image
            isLoading = false; // Set loading to false after image is uploaded
          });
        } else {
          setState(() {
            isLoading = false; // Stop loading if there is an error
          });
          print("Failed to upload image: ${response.error!.message}");
        }
      } catch (e) {
        setState(() {
          isLoading = false; // Stop loading if there is an error
        });
        print("Error uploading image: $e");
      }
    } else {
      setState(() {
        isLoading = false; // Stop loading if no image was picked
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
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                          child:
                              Container()), // Spacer to push content to the right
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
                            const SizedBox(height: 20),
                            _buildDetailRow(
                                "Number of Pets Catered per day:",
                                profileData?['number_of_pets']?.toString() ??
                                    ''),
                            const SizedBox(height: 20),
                            const Divider(),
                            const Text("Business Address:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            _buildDetailRow(
                              "Address:",
                              "${profileData?['address']?['floor_unit_room'] ?? ''}, "
                                  "${profileData?['address']?['street'] ?? ''}, "
                                  "${profileData?['address']?['barangay'] ?? ''}, "
                                  "${profileData?['address']?['city'] ?? ''}",
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
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}

extension on String {
  get error => null;
}
