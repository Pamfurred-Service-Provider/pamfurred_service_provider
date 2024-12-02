import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/Supabase/service_backend.dart';
import 'package:service_provider/screens/services.dart';

class AddServiceScreen extends StatefulWidget {
  final String serviceProviderId;
  final String? serviceCategory;

  const AddServiceScreen({
    super.key,
    required this.serviceProviderId,
    this.serviceCategory,
    required Map<String, dynamic> serviceData,
  });
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
  List<String> petsList = ['dog']; // List to store pets
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
  void addPet() async {
    List<String> availablePets =
        petType.where((pet) => !petsList.contains(pet)).toList();
    // If there are available pets left to choose, add another dropdown
    if (availablePets.isNotEmpty) {
      setState(() {
        petsList
            .add(availablePets.first); // Add the first available pet by default
      });
    } else {
      // Show a message if all pets are already selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All pets have been added.')),
      );
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
  }

  //Static data for pet sizes
  List<String> sizeOptions = ['S', 'M', 'L', 'XL', 'N/A'];
  final List<String> petType = ['dog', 'cat', 'bunny'];
  String? serviceType = 'In-clinic';
  String? availability = 'Available';
  String? sizes = 'S';

  void _addService() async {
    final backend = ServiceBackend();
    setState(() {
      _isLoading = true; // Start loading
    });
    int price, minWeight, maxWeight;

    try {
      // Parse and validate input fields
      price = int.parse(priceController.text);
      minWeight = int.parse(minWeightController.text);
      maxWeight = int.parse(maxWeightController.text);

      if (nameController.text.isEmpty ||
          priceController.text.isEmpty ||
          sizes == null ||
          minWeightController.text.isEmpty ||
          serviceType == null ||
          availability == null) {
        throw Exception('Please fill all fields');
      }

      // Upload image if provided
      String imageUrl = '';
      if (_image != null) {
        imageUrl = await backend.uploadImage(_image!);
      }

      // Add service to backend
      final serviceId = await backend.addService(
        serviceName: nameController.text,
        price: price,
        size: sizes ?? '',
        minWeight: minWeight,
        maxWeight: maxWeight,
        petsToCater: petsList,
        serviceProviderId: widget.serviceProviderId,
        serviceType: serviceType ?? '',
        availability: availability == 'Available',
        imageUrl: imageUrl,
        serviceCategory: widget.serviceCategory,
      );

      if (serviceId != null) {
        // Navigate to ServicesScreen after successful service addition
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ServicesScreen()),
        );
      } else {
        throw Exception('Failed to add service, please try again.');
      }
    } catch (e) {
      // Handle errors and show a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false); // Stop loading
    }
  }

  final serviceBackend = ServiceBackend();
  List<String> serviceNames = [];
  String? selectedService;

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      final services = await serviceBackend.fetchServiceName();
      setState(() {
        serviceNames = services;
      });
    } catch (error) {
      print('Error fetching services: $error');
    }
  }

  void addNewService(String newService) {
    setState(() {
      serviceNames.add(newService); // Add the new service to the list
      selectedService = newService; // Set the new service as selected
    });
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
          // Information about asterisk fields
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Fields marked with an asterisk (*) are required.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

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
                          ? const AssetImage(
                              'assets/pamfurred_secondarylogo.png')
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
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Service Name ', // Regular text
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*', // Asterisk in red
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedService,
            items: serviceNames
                .map((service) => DropdownMenuItem<String>(
                      value: service,
                      child: Text(service),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedService = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Select a Service',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final newService = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AddServiceDialog();
                },
              );

              if (newService != null && newService.isNotEmpty) {
                addNewService(newService);
              }
            },
            child: Text('Add New Service'),
          ),

          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Pet Specific Service ', // Regular text
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*', // Asterisk in red
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          ...petsList.asMap().entries.map((entry) {
            int index = entry.key;
            String pet = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: pet,
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              petsList[index] = newValue!;
                            });
                          },
                          items: petType
                              .where((petCategory) =>
                                  !petsList.contains(petCategory) ||
                                  petCategory == pet)
                              .map((petCategory) => DropdownMenuItem<String>(
                                    value: petCategory,
                                    child: Text(petCategory),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removePet(index),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),
          // Add more pets button
          ElevatedButton.icon(
            onPressed: addPet, // Add pet when pressed
            icon: const Icon(Icons.add),
            label: const Text("Add More"),
            // label: const Text("Add Pet Category"),
          ),

          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Availability ', // Regular text
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*', // Asterisk in red
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
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
                hint: const Text('Select Availability *'),
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
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Add a Size ', // Regular text
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*', // Asterisk in red
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
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
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Weight (in Kilograms) ', // Regular text
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*', // Asterisk in red
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
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
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Price (PHP) ', // Regular text
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*', // Asterisk in red
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),

          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*')), // Allows only digits
            ],
            controller: priceController,
            decoration: const InputDecoration(
              prefixText: '₱ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              hintText: "Enter price",
            ),
          ),

          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: 'Service Type ', // Regular text
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*', // Asterisk in red
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
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
                items: ['In-clinic', 'Home service'].map((String value) {
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

class AddServiceDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Service'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: 'Enter service name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cancel action
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
                context, _controller.text.trim()); // Return new service name
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
