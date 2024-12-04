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
import 'package:service_provider/components/capitalize_first_letter.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/width_expanded_button.dart';
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
  final TextEditingController descController = TextEditingController();
  // final TextEditingController priceController = TextEditingController();
  // final TextEditingController minWeightController = TextEditingController();
  // final TextEditingController maxWeightController = TextEditingController();
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

      priceControllers.add(TextEditingController());
      minWeightControllers.add(TextEditingController());
      maxWeightControllers.add(TextEditingController());
      availabilityMap[sizeList.last] = 'Available'; // Set default availability
    });

    // Check if adding a new entry still maintains the constraints
    if (sizeList.length > 2) {
      try {
        // Check if the list has at least one previous entry to validate against
        if (sizeList.length > 1) {
          // Parse the previous size values
          int prevPrice =
              int.tryParse(priceControllers[sizeList.length - 2].text.trim()) ??
                  -1;
          int prevMinWeight = int.tryParse(
                  minWeightControllers[sizeList.length - 2].text.trim()) ??
              -1;
          int prevMaxWeight = int.tryParse(
                  maxWeightControllers[sizeList.length - 2].text.trim()) ??
              -1;

          // Parse the current size values
          int currPrice = int.tryParse(priceControllers.last.text.trim()) ?? -1;
          int currMinWeight =
              int.tryParse(minWeightControllers.last.text.trim()) ?? -1;
          int currMaxWeight =
              int.tryParse(maxWeightControllers.last.text.trim()) ?? -1;

          // Validate all parsed values
          if (prevPrice < 0 ||
              prevMinWeight < 0 ||
              prevMaxWeight < 0 ||
              currPrice < 0 ||
              currMinWeight < 0 ||
              currMaxWeight < 0) {
            throw FormatException();
          }

          // Ensure current size is not less than the previous size
          if (currPrice < prevPrice ||
              currMinWeight < prevMinWeight ||
              currMaxWeight < prevMaxWeight) {
            showErrorDialog(
              context,
              "New size values must not be lesser than the previous size!",
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
      } catch (e) {
        showErrorDialog(
          context,
          "Invalid input detected. Please ensure all fields contain valid numeric values.",
        );

        // Remove the last entry in case of invalid input
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

  bool validateEntries() {
    // Check if price controllers are empty
    final prices = priceControllers.map((e) => e.text).toSet();
    if (prices.contains('')) {
      showErrorDialog(context, "Price fields cannot be empty!");
      return false;
    }

    // Check if weight fields are empty
    for (int i = 0; i < minWeightControllers.length; i++) {
      if (minWeightControllers[i].text.isEmpty ||
          maxWeightControllers[i].text.isEmpty) {
        showErrorDialog(context, "Weight fields cannot be empty!");
        return false;
      }
    }

    // Create the weights set
    final weights = {
      for (int i = 0; i < minWeightControllers.length; i++)
        '${minWeightControllers[i].text}-${maxWeightControllers[i].text}'
    };

    print("prices: $prices");
    print("weights: $weights");

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
      try {
        int prevPrice = int.parse(prices.elementAt(i - 1));
        int currPrice = int.parse(prices.elementAt(i));
        if (currPrice < prevPrice) {
          showErrorDialog(
            context,
            "Price for larger sizes should not be lesser!",
          );
          print("price: $prevPrice, $currPrice ");
          return false;
        }
      } catch (e) {
        showErrorDialog(context, "Invalid price format!");
        return false;
      }
    }

    // Validate the weights for increasing values as size increases
    for (int i = 0; i < minWeightControllers.length; i++) {
      try {
        // Clean the input before parsing
        int minWeight = int.parse(minWeightControllers[i].text);
        int maxWeight = int.parse(maxWeightControllers[i].text);

        if (i > 0) {
          int prevMinWeight = int.parse(minWeightControllers[i - 1].text);
          int prevMaxWeight = int.parse(maxWeightControllers[i - 1].text);

          if (minWeight < prevMinWeight || maxWeight < prevMaxWeight) {
            showErrorDialog(
              context,
              "Weight for larger sizes should not be lesser!",
            );
            print(
                "weights: $minWeight $maxWeight prev: $prevMinWeight $prevMaxWeight ");
            return false;
          }
        }
      } catch (e) {
        showErrorDialog(context, "Invalid weight format!");
        return false;
      }
    }
    print("VERY GOOD!");

    return true; // Return true if all validations pass
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

  Future<void> _addService() async {
    final backend = ServiceBackend();
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Attempt to parse input values
      int price;
      int minWeight;
      int maxWeight;

      try {
        price = int.parse(priceControllers[0].text.trim());
      } catch (e) {
        throw Exception(
            "Invalid price format. Received: '${priceControllers[0].text}'. Please enter a valid integer.");
      }

      try {
        minWeight = int.parse(minWeightControllers[0].text);
      } catch (e) {
        throw Exception(
            'Invalid maximum weight format. Received: \'${maxWeightControllers[0].text}\'. Please enter a valid integer.');
      }

      try {
        maxWeight = int.parse(maxWeightControllers[0].text);
      } catch (e) {
        throw Exception(
            'Invalid maximum weight format. Please enter a valid integer.');
      }

      // Validate input fields before proceeding
      if (nameController.text.isEmpty) {
        throw Exception('Service name cannot be empty');
      }
      if (descController.text.isEmpty) {
        throw Exception('Service description cannot be empty');
      }
      if (priceControllers[0].text.isEmpty) {
        throw Exception('Price cannot be empty');
      }
      if (sizes == null) {
        throw Exception('Size must be selected');
      }
      if (minWeightControllers[0].text.isEmpty) {
        throw Exception('Minimum weight cannot be empty');
      }
      if (serviceTypeOptions.isEmpty) {
        throw Exception('At least one service type must be selected');
      }
      if (availability == null) {
        throw Exception('Availability must be specified');
      }

      // Upload image if provided
      String imageUrl = '';
      if (_image != null) {
        try {
          imageUrl = await backend.uploadImage(_image!);
        } catch (uploadError) {
          throw Exception('Failed to upload image: $uploadError');
        }
      }

      // Add service to backend
      final serviceId = await backend.addService(
        serviceProviderId: widget.serviceProviderId,
        imageUrl: imageUrl,
        serviceName: nameController.text,
        serviceDesc: descController.text,
        petsToCater: petsList,
        serviceType: selectedServiceTypes,
        price: price,
        size: sizes ?? '',
        minWeight: minWeight,
        maxWeight: maxWeight,
        availability: availability == 'Available',
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
      // Handle exceptions gracefully
      print('Error occurred: $e');
      showErrorDialog(context, e.toString()); // Display the error to the user
    } finally {
      // Ensure loading state is reset
      setState(() {
        _isLoading = false; // Stop loading
      });
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
    priceControllers.add(TextEditingController());
    minWeightControllers.add(TextEditingController());
    maxWeightControllers.add(TextEditingController());
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
    return Stack(
      children: [
        Scaffold(
          appBar: customAppBarWithTitle(context, 'Add service'),
          backgroundColor: Colors.white,
          body: ListView(
            physics: BouncingScrollPhysics(),
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
                      text: 'Description ', // Regular text
                      style: const TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '*', // Asterisk in red
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: secondarySizedBox),
              SizedBox(
                height: 90,
                child: TextFormField(
                    minLines: 3,
                    maxLines: 5,
                    controller: descController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(secondaryBorderRadius),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: primaryColor),
                        borderRadius:
                            BorderRadius.circular(secondaryBorderRadius),
                      ),
                    ),
                    inputFormatters: [
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final newText = capitalizeFirstLetter(
                            newValue.text); // Capitalize only the first letter
                        return newValue.copyWith(text: newText);
                      }),
                    ]),
              ),
              const SizedBox(height: tertiarySizedBox),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'Service pet type ', // Regular text
                      style: const TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '*', // Asterisk in red
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: secondarySizedBox),
              CustomDropdown.multiSelect(
                decoration: CustomDropdownDecoration(
                  hintStyle: TextStyle(fontSize: smallText, color: greyColor),
                  closedBorder: Border.all(width: .75),
                  closedBorderRadius:
                      BorderRadius.circular(secondaryBorderRadius),
                  expandedBorder: Border.all(width: .75),
                  expandedBorderRadius:
                      BorderRadius.circular(secondaryBorderRadius),
                ),
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
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sizeList.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: tertiarySizedBox),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Size: ${sizeList[index]}",
                            style: const TextStyle(
                              fontSize: regularText,
                              fontWeight: boldWeight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: tertiarySizedBox),
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
                            icon: const Icon(Icons.delete, color: primaryColor),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ShowDeleteDialog(
                                    title: 'Confirm Deletion',
                                    content:
                                        'Are you sure you want to delete this service?',
                                    onDelete: () => removeEntry(index),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: tertiarySizedBox),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius)),
                              backgroundColor:
                                  availabilityMap[sizeList[index]] ==
                                          'Available'
                                      ? Colors.green
                                      : Colors.grey.shade300,
                              foregroundColor:
                                  availabilityMap[sizeList[index]] ==
                                          'Available'
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
                                  availabilityMap[sizeList[index]] =
                                      'Available';
                                });
                              }
                            },
                            child: const Text('Available'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius)),
                              backgroundColor:
                                  availabilityMap[sizeList[index]] ==
                                          'Not Available'
                                      ? primaryColor
                                      : Colors.grey.shade300,
                              foregroundColor:
                                  availabilityMap[sizeList[index]] ==
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
              const SizedBox(height: secondarySizedBox),
              CustomWideButton(
                text: 'Add more',
                onPressed: addEntry,
                leadingIcon: Icons.add,
                backgroundColor: Colors.green,
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'Service type ', // Regular text
                      style: const TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '*', // Asterisk in red
                      style: const TextStyle(color: primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: tertiarySizedBox),
              CustomDropdown.multiSelect(
                decoration: CustomDropdownDecoration(
                  hintStyle: TextStyle(fontSize: smallText, color: greyColor),
                  closedBorder: Border.all(width: .75),
                  closedBorderRadius:
                      BorderRadius.circular(secondaryBorderRadius),
                  expandedBorder: Border.all(width: .75),
                  expandedBorderRadius:
                      BorderRadius.circular(secondaryBorderRadius),
                ),
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
              const SizedBox(height: quaternarySizedBox),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius)),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(primarySizedBox),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: regularText),
                      ),
                    ),
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
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius)),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: regularText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54, // Semi-transparent background
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
