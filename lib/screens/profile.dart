import 'dart:io'; // Required to use File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'package:service_provider/screens/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

final List<String> store = ['Paws and Claws Pet Station', 'Groomers on the Go'];

class ProfileScreenState extends State<ProfileScreen> {
  File? _image; // Store the picked image file

  final ImagePicker _picker = ImagePicker();

  // Method to pick an image from the gallery
  Future<void> changeImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image =
            File(pickedFile.path); // Update the state with the selected image
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
                const Spacer(),
                Text(
                  store[0],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromRGBO(160, 62, 6, 1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
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
              ],
            ),
          ),
          Center(
            child: Stack(
              children: [
                _image == null
                    ? Image.asset(
                        'assets/paws_and_claws_logo.jpg',
                        width: 360,
                        height: 180,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        _image!, // Display the picked image
                        width: 230,
                        fit: BoxFit.contain,
                      ),
                Positioned(
                  bottom: 10,
                  right: 3,
                  child: ElevatedButton(
                    onPressed:
                        changeImage, // Call the changeImage method to pick an image
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 5),
                        Text("Edit Profile"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: Column(
            CrossAxisAlignment:CrossAxisAlignment.start,
            children: [
          Text("Establishment name"),
            ],
          ),
        ],
      ),
    );
  }
}
