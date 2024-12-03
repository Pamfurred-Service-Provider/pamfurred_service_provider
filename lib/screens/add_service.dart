import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/Supabase/service_backend.dart';
import 'package:service_provider/Widgets/add_service_dialog.dart';
import 'package:service_provider/Widgets/remove_pet_type.dart';
import 'package:service_provider/components/globals.dart';
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

  // Dynamic controllers for price, size, and weight
  List<TextEditingController> priceControllers = [];
  List<TextEditingController> minWeightControllers = [];
  List<TextEditingController> maxWeightControllers = [];
  List<String> sizeList = []; // Dynamic size list

  // Add new entry for price, size, and weight
  void addEntry() {
    setState(() {
      if (sizeList.isEmpty) {
        sizeList.add("S");
      } else if (sizeList.length < 4) {
        sizeList.add(["M", "L", "XL"][sizeList.length - 1]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can't add more than 4 sizes!")),
        );
        return;
      }

      priceControllers.add(TextEditingController(text: "0"));
      minWeightControllers.add(TextEditingController(text: "0"));
      maxWeightControllers.add(TextEditingController(text: "0"));
    });
  }

  // Remove an entry for price, size, and weight
  void removeEntry(int index) {
    if (index < sizeList.length &&
        index < priceControllers.length &&
        index < minWeightControllers.length &&
        index < maxWeightControllers.length) {
      setState(() {
        sizeList.removeAt(index);
        priceControllers.removeAt(index);
        minWeightControllers.removeAt(index);
        maxWeightControllers.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to remove entry: Invalid index.")),
      );
    }
  }

  // Validate and check for unique prices and weights
  bool validateEntries() {
    final prices = priceControllers.map((e) => e.text).toSet();
    final weights = {
      for (int i = 0; i < minWeightControllers.length; i++)
        '${minWeightControllers[i].text}-${maxWeightControllers[i].text}'
    };

    if (prices.length != priceControllers.length ||
        weights.length != minWeightControllers.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prices and weights must be unique!")),
      );
      return false;
    }

    return true;
  }

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

  void removePet(int index) {
    showDialog(
      context: context,
      builder: (context) => RemovePetTypeDialog(
        petsList: {'pet': petsList[index]},
        onDelete: () {
          setState(() {
            petsList.removeAt(index); // Remove pet from the list
          });
        },
      ),
    );
  }

  //Static data for pet sizes
  List<String> sizeOptions = ['S', 'M', 'L', 'XL', 'N/A'];
  List<String> serviceTypeOptions = ['Home Service', 'In-clinic'];
  List<String> selectedServiceTypes = [];
  List<String> petTypeOptions = ['dog', 'cat', 'bunny'];
  List<String> selectedPetTypes = [];
  final List<String> petType = ['dog', 'cat', 'bunny'];
  String? availability = 'Available';
  String? sizes = 'S';

  void _addService() async {
    final backend = ServiceBackend();
    setState(() {
      _isLoading = true; // Start loading
    });

    int price = int.parse(priceController.text);
    // String size = sizeList[0];
    int minWeight = int.parse(minWeightControllers[0].text);
    int maxWeight = int.parse(maxWeightControllers[0].text);
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        sizes == null ||
        minWeightController.text.isEmpty ||
        serviceTypeOptions == null ||
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
      serviceType: selectedServiceTypes,
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
  }

  final serviceBackend = ServiceBackend();
  List<String> serviceNames = [];
  String? selectedService;

  void addNewService(String newService) {
    setState(() {
      serviceNames.add(newService);
      selectedService = newService;
      nameController.text = newService;
    });
  }

  void selectService(String service) {
    setState(() {
      selectedService = service;
      nameController.text = service;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchServices();
    sizeList.add("S");
    priceControllers.add(TextEditingController(text: "0"));
    minWeightControllers.add(TextEditingController(text: "0"));
    maxWeightControllers.add(TextEditingController(text: "0"));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Service"),
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
          AddNewServiceDialog(
            nameController: nameController,
            serviceNames: serviceNames,
            selectedService: selectedService,
            onServiceSelected: selectService,
            onNewServiceAdded: addNewService,
          ),
          const SizedBox(height: tertiarySizedBox),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16),
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
          CustomDropdown.multiSelect(
            items: petTypeOptions,
            initialItems: selectedPetTypes,
            hintText: 'Select Pet Type',
            onListChanged: (List<String> selectedItems) {
              setState(() {
                selectedPetTypes = selectedItems;
              });
              print('Selected pet types: $selectedItems');
            },
          ),
          const SizedBox(height: tertiarySizedBox),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: 'Price, Size and Weights ', // Regular text
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*', // Asterisk in red
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: tertiarySizedBox),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sizeList.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Size: ${sizeList[index]}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Price
                      Expanded(
                        child: TextField(
                          controller: priceControllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: "Price",
                            prefixText: "₱ ",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Min Weight
                      Expanded(
                        child: TextField(
                          controller: minWeightControllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: "Min Weight",
                            suffixText: "kg",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Max Weight
                      Expanded(
                        child: TextField(
                          controller: maxWeightControllers[index],
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: "Max Weight",
                            suffixText: "kg",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeEntry(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Availability Toggle for Each Size
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: availability == 'Available'
                              ? Colors.green
                              : Colors.grey.shade300,
                          foregroundColor: availability == 'Available'
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            availability = 'Available';
                          });
                        },
                        child: const Text('Available'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: availability == 'Not Available'
                              ? Colors.red
                              : Colors.grey.shade300,
                          foregroundColor: availability == 'Not Available'
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            availability = 'Not Available';
                          });
                        },
                        child: const Text('Not Available'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
          ElevatedButton.icon(
            onPressed: addEntry,
            icon: const Icon(Icons.add),
            label: const Text("Add"),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: tertiarySizedBox),
          CustomDropdown.multiSelect(
            items: serviceTypeOptions,
            initialItems: selectedServiceTypes,
            hintText: 'Select Service Type',
            onListChanged: (List<String> selectedItems) {
              setState(() {
                selectedServiceTypes = selectedItems;
              });
              print('Selected service types: $selectedItems');
            },
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
                onPressed: _isLoading
                    ? null
                    : () {
                        if (validateEntries()) {
                          _addService();
                        }
                      },
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
