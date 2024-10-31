import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class AddPackageScreen extends StatefulWidget {
  const AddPackageScreen({super.key, this.packageData});
  final Map<String, dynamic>?
      packageData; //gamit ni sya para atong clickable nga card sa services

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController inclusionsController = TextEditingController();
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
  List<String> inclusionList = []; // List to store package inclusions
  String? packageType = 'Pet Salon';
  String? availability = 'Available';
  String? sizes = 'Small';

// Method to add pet to the list
  Future<void> _addInclusion() async {
    String? inclusion = await _showAddinclusionDialog();
    if (inclusion != null && inclusion.isNotEmpty) {
      setState(() {
        inclusionList.add(inclusion); // Add pet to the list
      });
    }
  }

  // Method to remove a pet from the list
  void _removeInclusion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Inclusion'),
        content: const Text('Are you sure you want to delete this?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => inclusionList.removeAt(index)); // Remove pet
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

// Dialog to input pet name
  Future<String?> _showAddinclusionDialog() async {
    String packageCategory = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Inclusion'),
          content: TextField(
            autofocus: true,
            decoration:
                const InputDecoration(hintText: 'Enter package inclusions'),
            onChanged: (value) {
              packageCategory = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without returning anything
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(packageCategory); // Return entered category
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.packageData != null) {
      // Initialize fields with data passed for editing
      nameController.text = widget.packageData?['name'] ?? '';
      descController.text = widget.packageData?['description'] ?? '';
      priceController.text = widget.packageData?['price'] ?? '';
      minWeightController.text = widget.packageData?['minWeight'] ?? '';
      maxWeightController.text = widget.packageData?['maxWeight'] ?? '';
      sizes = widget.packageData?['size'] ?? 'Small';
      inclusionList =
          List<String>.from(widget.packageData?['inclusionList'] ?? []);
      packageType = widget.packageData?['packageType'] ?? 'Pet Salon';
      availability = widget.packageData?['availability'] ?? 'Available';
      _image = widget.packageData?['image']; // Load the image if it exists
      // Initialize inclusionList from packageData
      inclusionList = widget.packageData?['inclusionList'] ??
          []; // Ensure it's a list of Strings
    }
  }

  void _savePackage() {
    final newPackage = {
      'name': nameController.text,
      'description': descController.text,
      'price': priceController.text,
      'size': sizes,
      'inclusionList': inclusionList,
      'minWeight': minWeightController.text,
      'maxWeight': maxWeightController.text,
      'packageType': packageType,
      'availability': availability,
      'image': _image, // Used for the service icon in the service screen
    };
    Navigator.pop(context, newPackage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Package"),
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
                          : FileImage(_image!),
                      fit: BoxFit.cover, // Cover the container
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
            "Package Name",
            style: TextStyle(fontSize: 16),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
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
            "Package Inclusions",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inclusionList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(
                            inclusionList[index],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color.fromRGBO(160, 62, 6, 1),
                            ),
                            onPressed: () {
                              _removeInclusion(
                                  index); // Remove inclusion from the list
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: _addInclusion,
              icon: const Icon(Icons.add),
              label: const Text("Add Inclusion"),
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
            "Input Weight (in kg)",
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
                value: packageType,
                onChanged: (newValue) {
                  setState(() {
                    packageType = newValue;
                  });
                },
                hint: const Text('Select Package Type'),
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
                onPressed: _savePackage,
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
