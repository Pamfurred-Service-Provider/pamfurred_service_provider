import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key, this.serviceData});
  final Map<String, dynamic>?
      serviceData; //gamit ni sya para atong clickable nga card sa services

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  //Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController minWeightController = TextEditingController();
  final TextEditingController maxWeightController = TextEditingController();

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

  //Static data for pet sizes
  List<String> sizeOptions = ['Small', 'Medium', 'Large', 'Extra Large', 'N/A'];

  String? serviceType = 'Pet Salon';
  String? availability = 'Available';
  String? sizes = 'Small';

  @override
  void initState() {
    super.initState();
    if (widget.serviceData != null) {
      // Initialize fields with data passed for editing
      nameController.text = widget.serviceData?['name'] ?? '';
      descController.text = widget.serviceData?['description'] ?? '';
      priceController.text = widget.serviceData?['price'] ?? '';
      minWeightController.text = widget.serviceData?['minWeight'] ?? '';
      maxWeightController.text = widget.serviceData?['maxWeight'] ?? '';
      sizes = widget.serviceData?['size'] ?? 'Small';
      serviceType = widget.serviceData?['serviceType'] ?? 'Pet Salon';
      availability = widget.serviceData?['availability'] ?? 'Available';
      _image = widget.serviceData?['image']; // Load the image if it exists
    }
  }

  void _saveService() {
    final newService = {
      'name': nameController.text,
      'description': descController.text,
      'price': priceController.text,
      'size': sizes,
      'minWeight': minWeightController.text,
      'maxWeight': maxWeightController.text,
      'serviceType': serviceType,
      'availability': availability,
      'image': _image, // Used for the service icon in the service screen
    };
    Navigator.pop(context, newService);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Service"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center, // Center the overlay text
              children: [
                Container(
                  width: 200, // Set width
                  height: 200, // Set height to the same value for a square
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.zero, // No rounding to keep it square
                    image: DecorationImage(
                      image: _image == null
                          ? const AssetImage('assets/image.png')
                          : FileImage(_image!) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
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
          ),
          const SizedBox(height: 20),
          const Text(
            "Service Name",
            style: TextStyle(fontSize: 16),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              // labelText: 'Service Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Description",
            style: TextStyle(fontSize: 16),
          ),
          TextField(
            maxLines: 8, // Allows the TextField to expand to 8 lines
            controller: descController,
            decoration: const InputDecoration(
              hintText: "Enter description here",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Availability",
            style: TextStyle(fontSize: 16),
          ),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: availability,
                onChanged: (newValue) {
                  setState(() {
                    availability = newValue;
                  });
                },
                hint: const Text('Select Availability'),
                items: ['Available', 'Unavailable'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add a Size",
            style: TextStyle(fontSize: 16),
          ),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: sizes,
                onChanged: (newValue) {
                  setState(() {
                    sizes = newValue;
                  });
                },
                hint: const Text('Sizes'),
                items: sizeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Weight (in kg)",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text("to"),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: maxWeightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Price (PHP)",
            style: TextStyle(fontSize: 16),
          ),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            controller: priceController,
            decoration: const InputDecoration(
              prefixText: '₱ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Service Type",
            style: TextStyle(fontSize: 16),
          ),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: serviceType,
                onChanged: (newValue) {
                  setState(() {
                    serviceType = newValue;
                  });
                },
                hint: const Text('Select Service Type'),
                items: ['Pet Salon', 'Home service'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFA03E06),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _saveService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 100, 176, 81),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
