import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/Supabase/package_backend.dart';
import 'package:service_provider/Widgets/add_package_dialog.dart';
import 'package:service_provider/Widgets/confirmation_dialog.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';
import 'package:service_provider/Widgets/error_dialog.dart';
import 'package:service_provider/components/capitalize_first_letter.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/providers/package_details_provider.dart';
import 'package:service_provider/providers/sp_details_provider.dart';

class UpdatePackageScreen extends ConsumerStatefulWidget {
  final String? packageCategory;
  final String? packageId;

  const UpdatePackageScreen(
      {super.key,
      this.packageCategory,
      required Map packageData,
      required this.packageId});

  @override
  ConsumerState<UpdatePackageScreen> createState() =>
      _UpdatePackageScreenState();
}

class _UpdatePackageScreenState extends ConsumerState<UpdatePackageScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController? descController = TextEditingController();
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
      // Check if any fields are empty or invalid before adding a new entry
      for (int i = 0; i < sizeList.length; i++) {
        if (priceControllers[i].text.trim().isEmpty ||
            minWeightControllers[i].text.trim().isEmpty ||
            maxWeightControllers[i].text.trim().isEmpty) {
          showErrorDialog(context,
              "Please complete all fields for size ${sizeList[i]} before adding a new size.");
          return; // Exit if any fields are not filled
        }

        // Validate price > 0
        int price = int.tryParse(priceControllers[i].text.trim()) ?? 0;
        if (price <= 0) {
          showErrorDialog(context,
              "Price for size ${sizeList[i]} must be greater than zero.");
          return; // Exit if price is zero or negative
        }

        // Validate max weight >= min weight
        int minWeight = int.tryParse(minWeightControllers[i].text.trim()) ?? 0;
        int maxWeight = int.tryParse(maxWeightControllers[i].text.trim()) ?? 0;

        if (maxWeight < minWeight) {
          showErrorDialog(context,
              "Max Weight for size ${sizeList[i]} cannot be less than Min Weight.");
          return; // Exit if the max weight is invalid
        }
      }

      // Ensure the new minimum weight is greater than the previous maximum weight
      if (sizeList.length > 1) {
        int prevMaxWeight = int.tryParse(
                maxWeightControllers[sizeList.length - 2].text.trim()) ??
            0;

        int newMinWeight =
            int.tryParse(minWeightControllers.last.text.trim()) ?? 0;

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

      // Add new controllers for the new size
      priceControllers.add(TextEditingController());
      minWeightControllers.add(TextEditingController());
      maxWeightControllers.add(TextEditingController());
      availabilityMap[sizeList.last] = 'Available'; // Set default availability
    });
  }

// Validate all fields when ready to submit
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

      // Validate max weight >= min weight
      int minWeight = int.tryParse(minWeightControllers[i].text.trim()) ?? 0;
      int maxWeight = int.tryParse(maxWeightControllers[i].text.trim()) ?? 0;

      if (maxWeight < minWeight) {
        showErrorDialog(context,
            "Max Weight for size ${sizeList[i]} cannot be less than Min Weight.");
        return; // Exit if the max weight is invalid
      }
    }

    // Existing checks for size constraints
    for (int i = 1; i < sizeList.length; i++) {
      try {
        int prevPrice = int.parse(priceControllers[i - 1].text.trim());
        int prevMinWeight = int.parse(minWeightControllers[i - 1].text.trim());
        int prevMaxWeight = int.parse(maxWeightControllers[i - 1].text.trim());

        int currPrice = int.parse(priceControllers[i].text.trim());
        int currMinWeight = int.parse(minWeightControllers[i].text.trim());
        int currMaxWeight = int.parse(maxWeightControllers[i].text.trim());

        if (prevPrice < 0 ||
            prevMinWeight < 0 ||
            prevMaxWeight < 0 ||
            currPrice < 0 ||
            currMinWeight < 0 ||
            currMaxWeight < 0) {
          showErrorDialog(context, "Values must be non-negative.");
          return;
        }

        if (currPrice < prevPrice ||
            currMinWeight < prevMinWeight ||
            currMaxWeight < prevMaxWeight) {
          showErrorDialog(context,
              "New size values must not be smaller than the previous size values!");
          return; // Exit if the new size values are invalid
        }
      } catch (e) {
        showErrorDialog(context,
            "Invalid input detected. Please ensure all fields contain valid numeric values.");
        return;
      }
    }
    // Proceed with the next steps (e.g., saving the data)
  }

  // Remove an entry for price, size, and weight
  void removeEntry(int index) {
    if (index < sizeList.length &&
        index < priceControllers.length &&
        index < minWeightControllers.length &&
        index < maxWeightControllers.length) {
      setState(() {
        final sizeToRemove = sizeList[index];

        sizeList.removeAt(index);
        priceControllers.removeAt(index);
        minWeightControllers.removeAt(index);
        maxWeightControllers.removeAt(index);
        availabilityMap.remove(sizeToRemove);
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
        showErrorDialog(context,
            "Price for larger sizes should not be lesser or equal to the previous price.");
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

  Future<void> _updatePackage() async {
    final backend = PackageBackend();
    setState(() {
      isLoading = true; // Start loading
    });

    String? imageUrl = null;
    if (_image != null) {
      try {
        final packageId = ref.watch(selectedPackageIdProvider);
        imageUrl = await backend.updatePackageImageById(packageId!, _image!);
      } catch (uploadError) {
        throw Exception('Failed to upload image: $uploadError');
      }
    }
    List<int> prices = [];
    List<int> minWeights = [];
    List<int> maxWeights = [];
    try {
      prices = priceControllers
          .map((controller) => int.parse(controller.text.trim()))
          .toList();
    } catch (e) {
      throw Exception(
          "Invalid price format in one or more fields. Please ensure all prices are valid integers.");
    }
    try {
      minWeights = minWeightControllers
          .map((controller) => int.parse(controller.text.trim()))
          .toList();
    } catch (e) {
      throw Exception(
          "Invalid minimum weight format in one or more fields. Please ensure all minimum weights are valid integers.");
    }
    try {
      maxWeights = maxWeightControllers
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

    print("Prices, min w, max w: $prices, $minWeights, $maxWeights");

    print('Sizes length: ${sizeList.length}');
    print('Prices length: ${prices.length}');
    print('Min Weights length: ${minWeights.length}');
    print('Max Weights length: ${maxWeights.length}');
    print('availability length: ${availabilityMap.length}');

    final packageProviderId = ref.watch(userIdProvider);

    final selectedPackageId = ref.watch(selectedPackageIdProvider);

    print("still working here!");

    final packageId = await backend.updatePackage(
      packageId: selectedPackageId,
      packageProviderId: packageProviderId, // petsToCater:
      packageName: nameController.text,
      packageDesc: descController?.text ?? '',
      imageUrl: imageUrl,
      size: sizeList,
      prices: prices,
      minWeight: minWeights,
      maxWeight: maxWeights,
      petsToCater: selectedPetTypes,
      packageType: selectedServiceTypes,
      availability: availabilityMap,
      inclusionList: inclusions,
      packageCategory: widget.packageCategory, // Pass package category here
    );
    if (packageId != null) {
      Navigator.pop(context, {
        'package_id': packageId,
        'package_name': nameController.text,
        'package_image': imageUrl, // or another appropriate property
        'price': prices.isNotEmpty ? prices.first : null,
      });
      print("success!");

    } else {
      throw Exception('Failed to add package');
    }
  }

  final serviceBackend = PackageBackend();
  List<Map<String, String>> serviceNamesWithCategories = [];
  String? selectedService;

  void addNewService(String newService) {
    setState(() {
      serviceNamesWithCategories.add({'service_name': newService});
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

  void removeService(String service) {
    setState(() {
      selectedServices.remove(service); // Remove service from selected list
    });
  }

  @override
  void initState() {
    super.initState();
    sizeList.add("S");
    availabilityMap["S"] = "Available";
    priceControllers.add(TextEditingController());
    minWeightControllers.add(TextEditingController());
    maxWeightControllers.add(TextEditingController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch services and pre-fill service details
    fetchServices();
    fetchPrefillPackages();
  }

  Future<void> fetchServices() async {
    try {
      final services = await serviceBackend.fetchServiceNamesWithCategories();
      setState(() {
        serviceNamesWithCategories = services;
        print("service names with category: $serviceNamesWithCategories");
      });
    } catch (error) {
      print('Error fetching services: $error');
    }
  }

  Future<void> fetchPrefillPackages() async {
    try {
      final packageId = ref.watch(selectedPackageIdProvider);
      final packageDetailsAsyncValue =
          ref.watch(fetchPackageDetailsProvider(packageId!));

      packageDetailsAsyncValue.when(
        data: (packageDetails) {
          if (packageDetails.isNotEmpty) {
            final package = packageDetails[0];

            // Pre-fill name and description
            nameController.text = package['package_name'] ?? '';
            descController?.text = package['package_desc'] ?? '';

            // Pre-fill pet types
            final petTypes = package['pet_type'] as List<dynamic>;
            selectedPetTypes = petTypes.map((e) => e.toString()).toList();
            petsToCaterController.text = selectedPetTypes.join(', ');

            // Clear existing lists
            sizeList.clear();
            priceControllers.clear();
            minWeightControllers.clear();
            maxWeightControllers.clear();
            inclusions.clear();

            // Populate based on fetched package details
            for (final detail in packageDetails) {
              // Extract size, price, weight, and availability
              final size = detail['size'] ?? '';
              final price = detail['price'] ?? '0';
              final minWeight = detail['min_weight'] ?? '0';
              final maxWeight = detail['max_weight'] ?? '0';
              final availability = detail['availability_status'];

              // Add size
              sizeList.add(size);

              // Add controllers
              priceControllers
                  .add(TextEditingController(text: price.toString()));
              minWeightControllers
                  .add(TextEditingController(text: minWeight.toString()));
              maxWeightControllers
                  .add(TextEditingController(text: maxWeight.toString()));

              // Update availability map
              availabilityMap[size] = availability;
            }

            // Pre-fill package types
            if (package['package_type'] is List) {
              selectedServiceTypes = (package['package_type'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
            }

            // Pre-fill inclusions
            if (package['inclusions'] is List) {
              inclusions = (package['inclusions'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();
            }
          } else {
            print("No package details found for the provided package ID.");
          }
        },
        loading: () {
          print("Loading package details...");
        },
        error: (error, stackTrace) {
          print('Error fetching services: $error');
        },
      );
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
                      text: 'Description ', // Regular text
                      style: const TextStyle(color: Colors.black),
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
                      hintText: 'Enter description',
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
              AddNewPackageDialog(
                searchController: searchController,
                serviceNamesWithCategories: serviceNamesWithCategories,
                packageCategory: widget.packageCategory,
                selectedServices:
                    inclusions, // Pass the selected services list here
                onServicesSelected: (List<String> updatedServices) {
                  setState(() {
                    inclusions = updatedServices; // Update selected services
                  });
                },
                onNewServiceAdded: (String newService) {
                  setState(() {
                    serviceNamesWithCategories.add(
                        {'service_name': newService}); // Add the new service
                    inclusions.add(newService); // Optionally add to inclusions
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
                  // Variable to hold the default min weight and price
                  String? defaultMinWeight;
                  String? defaultPrice;

                  // Set default values based on previous entry
                  if (index > 0) {
                    // Get the previous size's max weight
                    int prevMaxWeight = int.tryParse(
                            maxWeightControllers[index - 1].text.trim()) ??
                        0;
                    defaultMinWeight = (prevMaxWeight + 1)
                        .toString(); // Default to prev max + 1

                    // Get the previous size's price
                    int prevPrice =
                        int.tryParse(priceControllers[index - 1].text.trim()) ??
                            0;
                    defaultPrice =
                        prevPrice.toString(); // Default to the previous price
                  }

                  // If it's a new entry, create new controllers for minWeight and price
                  if (defaultMinWeight != null &&
                      minWeightControllers[index].text.isEmpty) {
                    minWeightControllers[index] =
                        TextEditingController(text: defaultMinWeight);
                  }

                  if (defaultPrice != null &&
                      priceControllers[index].text.isEmpty) {
                    priceControllers[index] =
                        TextEditingController(text: defaultPrice);
                  }

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
                              decoration: InputDecoration(
                                labelText: "Price",
                                prefixText: "₱ ",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius),
                                ),
                                labelStyle: const TextStyle(fontSize: 13),
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
                              decoration: InputDecoration(
                                labelText: "Min Weight",
                                suffixText: "kg",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius),
                                ),
                                labelStyle: const TextStyle(fontSize: 12),
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
                              decoration: InputDecoration(
                                labelText: "Max Weight",
                                suffixText: "kg",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      secondaryBorderRadius),
                                ),
                                labelStyle: const TextStyle(fontSize: 12),
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
                                    secondaryBorderRadius),
                              ),
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
                              bool? confirmed = await ConfirmationDialog.show(
                                context,
                                title: 'Change Availability',
                                content:
                                    'Are you sure you want to mark this as Available?',
                              );

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
                                    secondaryBorderRadius),
                              ),
                              backgroundColor:
                                  availabilityMap[sizeList[index]] ==
                                          'Unavailable'
                                      ? secondaryColor
                                      : Colors.grey.shade300,
                              foregroundColor:
                                  availabilityMap[sizeList[index]] ==
                                          'Unavailable'
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            onPressed: () async {
                              bool? confirmed = await ConfirmationDialog.show(
                                context,
                                title: 'Change Availability',
                                content:
                                    'Are you sure you want to mark this as Not Available?',
                              );

                              if (confirmed == true) {
                                setState(() {
                                  availabilityMap[sizeList[index]] =
                                      'Unavailable';
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
                backgroundColor: primaryColor,
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
                      backgroundColor: Color.fromRGBO(244, 67, 54, 1.0),
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
                              _updatePackage();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(secondaryBorderRadius)),
                      backgroundColor: Colors.green,
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
