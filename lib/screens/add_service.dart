import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/Supabase/service_backend.dart';

class AddServiceScreen extends StatefulWidget {
  final String serviceProviderId;
  final String? serviceCategory;

  AddServiceScreen({
    super.key,
    required this.serviceProviderId,
    this.serviceCategory,
  }) {
    print('Service Category in AddServiceScreen: $serviceCategory'); // Debug
  }
  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  //Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController minWeightController = TextEditingController();
  final TextEditingController maxWeightController = TextEditingController();
  final TextEditingController petsToCaterController = TextEditingController();

  File? _image; // Store the picked image file
  final ImagePicker _picker = ImagePicker();
  List<String> petsList = []; // List to store pets
  bool _isLoading = false;
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

// Method to add pet to the list
  Future<void> _addPet() async {
    String? newPet = await _showAddPetDialog();
    if (newPet != null && newPet.isNotEmpty) {
      setState(() {
        petsList.add(newPet); // Add pet to the list
      });
    }
  }

  // Method to remove a pet from the list
  void _removePet(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: const Text('Are you sure you want to delete this?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => petsList.removeAt(index)); // Remove pet
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  } // Dialog to input pet name

  Future<String?> _showAddPetDialog() async {
    String petCategory = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Pet'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter pet type'),
            onChanged: (value) {
              petCategory = value;
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
                    .pop(petCategory); // Return entered category
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  //Static data for pet sizes
  List<String> sizeOptions = ['S', 'M', 'L', 'XL', 'N/A'];

  String? serviceType = 'Pet Salon';
  String? availability = 'Available';
  String? sizes = 'S';

  void _addService() async {
    final backend = ServiceBackend();
    setState(() {
      _isLoading = true; // Start loading
    });
    int price;
    int minWeight;
    int maxWeight;
    try {
      price = int.parse(priceController.text);
    } catch (e) {
      print("Invalid price input.");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      minWeight = int.parse(minWeightController.text);
    } catch (e) {
      print("Invalid minWeight input.");
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      if (nameController.text.isEmpty ||
          priceController.text.isEmpty ||
          sizes == null ||
          minWeightController.text.isEmpty ||
          serviceType == null ||
          availability == null) {
        throw Exception('Please fill all fields');
      }
      int price = int.parse(priceController.text);
      int minWeight = int.parse(minWeightController.text);
      int maxWeight = int.parse(maxWeightController.text);

      print("Adding service with category: ${widget.serviceCategory}");
      print("Name: ${nameController.text}");
      print("Pet Specific Service: $petsList");
      print("Price: $price");
      print("Size: $sizes");
      print("serviceType: $serviceType");
      print("Min Weight: $minWeight");
      print("Max Weight: $maxWeight");
      print("Availability: $availability");
      print("Service Category: ${widget.serviceCategory}"); // Debug print
      final serviceId = await backend.addService(
        serviceName: nameController.text,
        price: price,
        size: sizes ?? '',
        minWeight: minWeight,
        maxWeight: maxWeight,
        petsToCater: petsList,
        serviceProviderId: widget.serviceProviderId, // petsToCater:
        //     petsToCaterController.text.split(',').map((e) => e.trim()).toList(),
        serviceType: serviceType ?? '',
        availability: availability == 'Available',
        image: _image,
        serviceCategory: widget.serviceCategory, // Pass service category here
      );
      print("Service ID returned: $serviceId");

      if (serviceId != null) {
        await backend.addServiceProviderService(
          serviceProviderId: widget.serviceProviderId,
          serviceId: serviceId.toString(),
        );
        print("Service provider service added successfully");

        Navigator.pop(context, 'Service Added');
      } else {
        throw Exception('Failed to add service: serviceId is null');
      }
    } catch (e) {
      print('Error adding service: ${e.toString()}');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add service. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Enter service name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Pet Specific Service",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: petsList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Text(
                      petsList[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Color.fromRGBO(160, 62, 6, 1),
                      ),
                      onPressed: () {
                        _removePet(index); // Remove pet from the list
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _addPet, // Add pet when pressed
            icon: const Icon(Icons.add),
            label: const Text("Add More"),
            // label: const Text("Add Pet Category"),
          ),
          const SizedBox(height: 10),
          const Text(
            "Availability",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minWeightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
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
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                onPressed: _addService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 100, 176, 81),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
