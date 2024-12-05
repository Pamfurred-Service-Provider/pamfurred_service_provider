import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/Supabase/package_backend.dart';
import 'package:service_provider/Widgets/add_service_dialog.dart';
import 'package:service_provider/Widgets/confirmation_dialog.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';
import 'package:service_provider/Widgets/error_dialog.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/screens/services.dart';

class AddPackageScreen extends StatefulWidget {
  final String packageProviderId;
  final String? packageCategory;

  const AddPackageScreen(
      {super.key,
      required this.packageProviderId,
      this.packageCategory,
      required Map packageData});

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController inclusionsController = TextEditingController();
  final TextEditingController petsToCaterController = TextEditingController();

  // Dynamic controllers for price, size, and weight
  List<TextEditingController> priceControllers = [];
  List<TextEditingController> minWeightControllers = [];
  List<TextEditingController> maxWeightControllers = [];
  List<String> sizeList = []; // Dynamic size list
  Map<String, String> availabilityMap = {};

  void addEntry() {
    setState(() {
      // Check if any fields are empty before adding a new entry
      for (int i = 0; i < sizeList.length; i++) {
        if (priceControllers[i].text.trim().isEmpty ||
            minWeightControllers[i].text.trim().isEmpty ||
            maxWeightControllers[i].text.trim().isEmpty) {
          showErrorDialog(context,
              "Please complete all fields for size ${sizeList[i]} before adding a new size.");
          return; // Exit if any fields are not filled
        }
      }
      // Ensure the new minimum weight is greater than the previous maximum weight
      if (sizeList.length > 1) {
        // Only check if there is more than one size
        // Get the previous size's maximum weight
        int prevMaxWeight = int.tryParse(
                maxWeightControllers[sizeList.length - 2].text.trim()) ??
            0;

        // Initialize new min weight as 0 and set when creating the new controller
        int newMinWeight = 0;

        // Only set newMinWeight if there's a valid last entry
        if (minWeightControllers.last.text.isNotEmpty) {
          newMinWeight =
              int.tryParse(minWeightControllers.last.text.trim()) ?? 0;
        }

        // Validate newMinWeight against the previous max weight
        if (newMinWeight <= prevMaxWeight) {
          showErrorDialog(context,
              "New size's Min Weight must be greater than the previous size's Max Weight (${prevMaxWeight}kg)!");
          return; // Exit if the new min weight is not valid
        }
      }
      // Add new size
      if (sizeList.isEmpty) {
        sizeList.add("S");
      } else if (sizeList.length < 4) {
        sizeList.add(["M", "L", "XL"][sizeList.length - 1]);
      } else {
        showErrorDialog(context, "You can't add more than 4 sizes!");
        return;
      }
      priceControllers.add(TextEditingController());
      minWeightControllers.add(TextEditingController());
      maxWeightControllers.add(TextEditingController());
      availabilityMap[sizeList.last] = 'Available'; // Set default availability
    });
  }

  void validateAndSubmit() {
    // Check if all fields for each size are filled
    for (int i = 0; i < sizeList.length; i++) {
      if (priceControllers[i].text.trim().isEmpty ||
          minWeightControllers[i].text.trim().isEmpty ||
          maxWeightControllers[i].text.trim().isEmpty) {
        showErrorDialog(context,
            "Please complete all fields for size ${sizeList[i]} before submitting.");
        return; // Exit if any fields are not filled
      }
    }

    // Now that all fields are filled, you can perform your existing checks
    for (int i = 1; i < sizeList.length; i++) {
      int prevPrice = int.parse(priceControllers[i - 1].text.trim());
      int prevMinWeight = int.parse(minWeightControllers[i - 1].text.trim());
      int prevMaxWeight = int.parse(maxWeightControllers[i - 1].text.trim());

      // Parse the current size values
      int currPrice = int.parse(priceControllers[i].text.trim());
      int currMinWeight = int.parse(minWeightControllers[i].text.trim());
      int currMaxWeight = int.parse(maxWeightControllers[i].text.trim());

      // Validate all parsed values
      if (prevPrice < 0 ||
          prevMinWeight < 0 ||
          prevMaxWeight < 0 ||
          currPrice < 0 ||
          currMinWeight < 0 ||
          currMaxWeight < 0) {
        showErrorDialog(context, "Values must be non-negative.");
        return;
      }

      // Ensure current size is not less than the previous size
      if (currPrice < prevPrice ||
          currMinWeight < prevMinWeight ||
          currMaxWeight < prevMaxWeight) {
        showErrorDialog(
          context,
          "New size values must not be lesser than the previous size!",
        );
      }
    }
  }

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
    final price = priceControllers.map((e) => e.text).toSet();
    if (price.contains('')) {
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
    } // Create the weights set
    final weights = {
      for (int i = 0; i < minWeightControllers.length; i++)
        '${minWeightControllers[i].text}-${maxWeightControllers[i].text}'
    };

    print("price: $price");
    print("weights: $weights");

    // Validate the price for increasing values as size increases
    for (int i = 1; i < priceControllers.length; i++) {
      try {
        int prevPrice = int.parse(price.elementAt(i - 1));
        int currPrice = int.parse(price.elementAt(i));
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
    return true;
  }

  File? _image; // Store the picked image file
  final ImagePicker _picker = ImagePicker();
  List<String> petsList = []; // List to store pets
  List<String> inclusions = [];
  bool isLoading = false;
  String? packageType = 'In-clinic';
  String? availability = 'Available';
  String? size = 'S';

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

  List<String> serviceTypeOptions = ['Home Service', 'In-clinic'];
  List<String> selectedServiceTypes = [];
  List<String> petTypeOptions = ['dog', 'cat', 'bunny'];
  List<String> selectedPetTypes = [];
  List<String> selectedServices = []; // List to hold selected services
// Method to add pet to the list
  void updateAvailability(String size, String status) {
    setState(() {
      availabilityMap[size] = status;
    });
  }

  void addPackage() async {
    final backend = PackageBackend();
    setState(() {
      isLoading = true; // Start loading
    });

    String imageUrl = '';
    if (_image != null) {
      imageUrl = await backend
          .uploadImage(_image!); // Get the image URL after uploading
    }
    List<int> price = [];
    List<int> minWeight = [];
    List<int> maxWeight = [];
    try {
      price = priceControllers
          .map((controller) => int.parse(controller.text.trim()))
          .toList();
    } catch (e) {
      throw Exception(
          "Invalid price format in one or more fields. Please ensure all price are valid integers.");
    }
    try {
      minWeight = minWeightControllers
          .map((controller) => int.parse(controller.text.trim()))
          .toList();
    } catch (e) {
      throw Exception(
          "Invalid minimum weight format in one or more fields. Please ensure all minimum weights are valid integers.");
    }
    try {
      maxWeight = maxWeightControllers
          .map((controller) => int.parse(controller.text.trim()))
          .toList();
    } catch (e) {
      throw Exception(
          "Invalid maximum weight format in one or more fields. Please ensure all maximum weights are valid integers.");
    }
    // Validate input fields before proceeding
    if (nameController.text.isEmpty) {
      throw Exception('Service name cannot be empty');
    }
    if (priceControllers.isEmpty) {
      throw Exception('Price cannot be empty');
    }
    if (minWeightControllers.isEmpty) {
      throw Exception('Minimum weight cannot be empty');
    }
    if (maxWeightControllers.isEmpty) {
      throw Exception('Maximum weight cannot be empty');
    }
    if (serviceTypeOptions.isEmpty) {
      throw Exception('At least one service type must be selected');
    }
    if (availability == null) {
      throw Exception('Availability must be specified');
    }

    final packageId = await backend.addPackage(
      packageProviderId: widget.packageProviderId, // petsToCater:
      packageName: nameController.text,
      imageUrl: imageUrl,
      size: sizeList,
      price: price,
      minWeight: minWeight,
      maxWeight: maxWeight,
      petsToCater: selectedPetTypes,
      packageType: packageType!,
      availability: availabilityMap,
      inclusionList: inclusions,
      packageCategory: widget.packageCategory, // Pass package category here
    );
    if (packageId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ServicesScreen()),
      );
    } else {
      throw Exception('Failed to add package');
    }
  }

  final serviceBackend = PackageBackend();
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
      if (!selectedServices.contains(service)) {
        selectedServices.add(service); // Add selected service to the list
      }
    });
  }

  void removeService(String service) {
    setState(() {
      selectedServices.remove(service); // Remove service from selected list
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
          appBar: customAppBarWithTitle(context, 'Add package'),
          backgroundColor: Colors.white,
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
              const SizedBox(height: tertiarySizedBox),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16),
                  children: [
                    TextSpan(
                      text: 'Package Name ',
                      style: const TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '*',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              TextField(
                textCapitalization: TextCapitalization.words,
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Enter package name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
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
                      text: 'Package Inclusions ',
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
                onServiceSelected: (String service) {
                  setState(() {
                    if (!inclusions.contains(service)) {
                      inclusions.add(service);
                    }
                  });
                },
                onNewServiceAdded: (String newService) {
                  setState(() {
                    serviceNames.add(newService);
                    inclusions.add(newService);
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Selected Services:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Chips to display selected services
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: inclusions.isEmpty
                    ? const Text(
                        'No services selected',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: inclusions.map((service) {
                          return Chip(
                            backgroundColor: Colors.blue.shade50,
                            label: Text(
                              service,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 18,
                              color: primaryColor,
                            ),
                            onDeleted: () {
                              setState(() {
                                inclusions.remove(service);
                              });
                            },
                          );
                        }).toList(),
                      ),
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
                      Text(
                        "Size: ${sizeList[index]}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                            icon: const Icon(Icons.delete, color: primaryColor),
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
                    onPressed: isLoading
                        ? null
                        : () {
                            if (validateEntries()) {
                              addPackage();
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
        if (isLoading)
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
