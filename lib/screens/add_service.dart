import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/Supabase/service_backend.dart';
import 'package:service_provider/Widgets/add_service_dialog.dart';
import 'package:service_provider/Widgets/confirmation_dialog.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';
import 'package:service_provider/Widgets/error_dialog.dart';
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
  Map<String, String> availabilityMap = {};

  // Add new entry for price, size, and weight
  void addEntry() {
    setState(() {
      if (sizeList.isEmpty) {
        sizeList.add("S");
      } else if (sizeList.length < 4) {
        sizeList.add(["M", "L", "XL"][sizeList.length - 1]);
      } else {
        showErrorDialog(
          context,
          "You can't add more than 4 sizes!",
        );

        return;
      }

      priceControllers.add(TextEditingController(text: "0"));
      minWeightControllers.add(TextEditingController(text: "0"));
      maxWeightControllers.add(TextEditingController(text: "0"));
      availabilityMap[sizeList.last] = 'Available'; // Set default availability
    });

    // Check if adding a new entry still maintains the constraints
    if (sizeList.length > 1) {
      int prevPrice = int.parse(priceControllers[sizeList.length - 2].text);
      int prevMinWeight =
          int.parse(minWeightControllers[sizeList.length - 2].text);
      int prevMaxWeight =
          int.parse(maxWeightControllers[sizeList.length - 2].text);

      int currPrice = int.parse(priceControllers.last.text);
      int currMinWeight = int.parse(minWeightControllers.last.text);
      int currMaxWeight = int.parse(maxWeightControllers.last.text);

      // Ensure current size is not less than the previous size
      if (currPrice < prevPrice ||
          currMinWeight < prevMinWeight ||
          currMaxWeight < prevMaxWeight) {
        showErrorDialog(
          context,
          "New size values must not be lesser than the previous size.!",
        );

        // Remove the newly added entry if validation fails
        setState(() {
          sizeList.removeLast();
          priceControllers.removeLast();
          minWeightControllers.removeLast();
          maxWeightControllers.removeLast();
        });
      }
    }
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
      showErrorDialog(
        context,
        "Unable to remove entry!",
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

    // Ensure prices and weights are unique
    if (prices.length != priceControllers.length ||
        weights.length != minWeightControllers.length) {
      showErrorDialog(
        context,
        "Prices and weights must be unique!",
      );
      return false;
    }

    // Validate the price for increasing values as size increases
    for (int i = 1; i < priceControllers.length; i++) {
      int prevPrice = int.parse(priceControllers[i - 1].text);
      int currPrice = int.parse(priceControllers[i].text);
      if (currPrice < prevPrice) {
        showErrorDialog(
          context,
          "Price for larger sizes should not be lesser!",
        );
        return false;
      }
    }

    // Validate the weights for increasing values as size increases
    for (int i = 1; i < minWeightControllers.length; i++) {
      int prevMinWeight = int.parse(minWeightControllers[i - 1].text);
      int currMinWeight = int.parse(minWeightControllers[i].text);
      int prevMaxWeight = int.parse(maxWeightControllers[i - 1].text);
      int currMaxWeight = int.parse(maxWeightControllers[i].text);

      if (currMinWeight < prevMinWeight || currMaxWeight < prevMaxWeight) {
        showErrorDialog(
          context,
          "Weight for larger sizes should not be lesser!",
        );
        return false;
      }
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

  //Static data for pet sizes
  List<String> sizeOptions = ['S', 'M', 'L', 'XL', 'N/A'];
  List<String> serviceTypeOptions = ['Home Service', 'In-clinic'];
  List<String> selectedServiceTypes = [];
  List<String> petTypeOptions = ['dog', 'cat', 'bunny'];
  List<String> selectedPetTypes = [];
  final List<String> petType = ['dog', 'cat', 'bunny'];
  String? availability = 'Available';
  String? sizes = 'S';

  void updateAvailability(String size, String status) {
    setState(() {
      availabilityMap[size] = status;
    });
  }

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
          const SizedBox(height: tertiarySizedBox),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: 'Service Name ',
                  style: const TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: '*',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
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
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ShowDeleteDialog(
                                title: 'Confirm Deletion',
                                content:
                                    'Are you sure you want to delete this?',
                                onDelete: () => removeEntry(index),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              availabilityMap[sizeList[index]] == 'Available'
                                  ? Colors.green
                                  : Colors.grey.shade300,
                          foregroundColor:
                              availabilityMap[sizeList[index]] == 'Available'
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        onPressed: () async {
                          // Show the confirmation dialog
                          bool? confirmed = await ConfirmationDialog.show(
                            context,
                            title: 'Change Availability',
                            content:
                                'Are you sure you want to mark this as Available?',
                          );

                          // If the user confirms, update the availability
                          if (confirmed == true) {
                            setState(() {
                              availabilityMap[sizeList[index]] = 'Available';
                            });
                          }
                        },
                        child: const Text('Available'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: availabilityMap[sizeList[index]] ==
                                  'Not Available'
                              ? Colors.red
                              : Colors.grey.shade300,
                          foregroundColor: availabilityMap[sizeList[index]] ==
                                  'Not Available'
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () async {
                          // Show the confirmation dialog
                          bool? confirmed = await ConfirmationDialog.show(
                            context,
                            title: 'Change Availability',
                            content:
                                'Are you sure you want to mark this as Not Available?',
                          );

                          // If the user confirms, update the availability
                          if (confirmed == true) {
                            setState(() {
                              availabilityMap[sizeList[index]] =
                                  'Not Available';
                            });
                          }
                        },
                        child: const Text('Not Available'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: addEntry,
            icon: const Icon(Icons.add),
            label: const Text("Add"),
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: 'Service Type', // Regular text
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
