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
import 'package:service_provider/components/globals.dart';
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
  // final TextEditingController priceController = TextEditingController();
  final TextEditingController inclusionsController = TextEditingController();
  // final TextEditingController minWeightController = TextEditingController();
  //final TextEditingController maxWeightController = TextEditingController();
  final TextEditingController petsToCaterController = TextEditingController();

  // Dynamic controllers for price, size, and weight
  List<TextEditingController> priceControllers = [];
  List<TextEditingController> minWeightControllers = [];
  List<TextEditingController> maxWeightControllers = [];
  List<String> sizeList = []; // Dynamic size list
  Map<String, String> availabilityMap = {};

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
    } // Create the weights set
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
      int prevPrice = int.parse(prices.elementAt(i - 1));
      int currPrice = int.parse(prices.elementAt(i));
      if (currPrice < prevPrice) {
        showErrorDialog(
          context,
          "Price for larger sizes should not be lesser!",
        );
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
  List<String> petsList = []; // List to store pets
  List<String> inclusions = [];
  bool isLoading = false;
  String? packageType = 'In-clinic';
  String? availability = 'Available';
  String? sizes = 'S';

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

    final packageId = await backend.addPackage(
      packageName: nameController.text,
      price: price,
      size: sizes ?? '',
      minWeight: minWeight,
      maxWeight: maxWeight,
      petsToCater: selectedPetTypes,
      packageProviderId: widget.packageProviderId, // petsToCater:
      packageType: packageType ?? '',
      availability: availability == 'Available',
      inclusionList: inclusions,
      imageUrl: imageUrl,
      packageCategory: widget.packageCategory, // Pass package category here
    );
    if (packageId != null) {
      // final newPackage = {
      //   'package_id': packageId,
      //   'name': nameController.text,
      //   'price': price,
      //   'size': sizes ?? '',
      //   'min_weight': minWeight,
      //   'max_weight': maxWeight,
      //   'pets_to_cater': petsList,
      //   'package_provider_id': widget.packageProviderId,
      //   'package_type': packageType ?? '',
      //   'availability': availability,
      //   'inclusion_list': inclusions,
      //   'image_url': imageUrl,
      //   'package_category': widget.packageCategory,
      // };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ServicesScreen()),
      );
    } else {
      throw Exception('Failed to add package: packageId is null');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Package"),
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
                          color: Colors.red,
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
                onPressed: addPackage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 100, 176, 81),
                  foregroundColor: Colors.white,
                ),
                child: isLoading
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
