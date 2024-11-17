import 'package:flutter/material.dart';
import 'package:service_provider/Widgets/error_dialog.dart';
import 'package:service_provider/screens/add_package.dart';
import 'package:service_provider/screens/add_service.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';
import 'package:service_provider/screens/package_details.dart';
import 'package:service_provider/screens/service_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen> {
  final supabase = Supabase.instance.client;
  String? serviceProviderId; // Nullable to allow dynamic assignment
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> packages = [];
  String? selectedCategory = 'All services'; // Default selected category
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final serviceSession = supabase.auth.currentSession;
    if (serviceSession == null) {
      throw Exception("User not logged in");
    }
    final userId = serviceSession.user.id;
    print('User ID: $userId');

// Fetch the service provider ID (sp_id) using user_id
    final spResponse = await supabase
        .from('service_provider')
        .select('sp_id')
        .eq('sp_id', userId)
        .single();

    if (spResponse == null || spResponse['sp_id'] == null) return;

    // Assign the retrieved sp_id
    serviceProviderId = spResponse['sp_id'];

    // Now fetch the services and packages
    await _fetchServices();
    await _fetchPackages();
  }

  Future<void> _fetchServices() async {
    if (serviceProviderId == null) return;

    final response = await supabase
        .from('serviceprovider_service')
        .select(
            'service_id, service(service_name, price, service_image, service_type, pet_type, size, min_weight, max_weight, availability_status)')
        .eq('sp_id', serviceProviderId);

    print("Supabase response: $response"); // Debugging line to inspect the data

    // Check if the response contains data
    if (response is List && response.isNotEmpty) {
      setState(() {
        services = List<Map<String, dynamic>>.from(response.map((item) {
          final service = item['service'];
          return {
            'id': item['service_id'],
            'name': item['service']['service_name'] ?? 'Unknown',
            'price': item['service']['price'] ?? 0,
            'image': item['service']['service_image'] ??
                'assets/images/default_image.png', // Default image path
            'type': (service['service_type'] as List).join(', '),
            'pets': (service['pet_type'] as List).join(', '),
            'size': item['service']['size'] ?? 'Unknown',
            'minWeight': item['service']['min_weight'] ?? 0,
            'maxWeight': item['service']['max_weight'] ?? 0,
            'availability': (service['availability_status'] is bool)
                ? (service['availability_status'] ? 'Available' : 'Unavailable')
                : service['availability_status'] ?? 'Unknown',
          };
        }));
      });
    } else {
      setState(() {
        services = [];
      });
    }
  }

  Future<void> _createService(Map<String, dynamic> newService) async {
    final response = await supabase.from('serviceprovider_service').insert({
      'sp_id': serviceProviderId,
      'service_id': newService['service_id'],
      'service_category': selectedCategory,
      'price': newService['price'],
    });

    if (response != null) {
      throw Exception('Failed to create service: ${response.message}');
    }
    await _fetchServicesByCategory(selectedCategory!);

    setState(() {
      services.add(newService);
    });
  }

  void _navigateToAddService(BuildContext context) async {
    if (serviceProviderId != null) {
      // Check if it's non-null
      final newService = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddServiceScreen(
            serviceProviderId: serviceProviderId!, // Pass non-null value
            serviceCategory: selectedCategory,
          ),
        ),
      );

      if (newService != null) {
        await _createService(newService);
      }
    } else {
      showErrorDialog(context, "Service Provider ID is missing.");
    }
  }

  void _navigateToServiceDetails(
      BuildContext context, Map<String, dynamic> serviceData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetails(
            serviceData: serviceData), // Passing the service data
      ),
    );
  }
// Delete service from Supabase

  Future<void> _deleteService(Map<String, dynamic> service) async {
    final serviceId = service['id'];
    final imageUrl = service['service_image'];

    print("Deleting service with ID: $service['id']");
    print("Service Provider ID: $serviceProviderId");

    try {
      // Delete the image from the bucket (if URL exists)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final fileName =
            imageUrl.split('/').last; // Get the file name from the URL
        final filePath =
            'service_images/$fileName'; // Construct the full path for service images

        final response = await supabase.storage
            .from('service_provider_images')
            .remove([filePath]);

        print("Image deleted from the bucket successfully.");
      } else {
        print("No image found to delete.");
      }

      // First, delete from the bridge table
      await supabase
          .from('serviceprovider_service')
          .delete()
          .match({'sp_id': serviceProviderId, 'service_id': serviceId});

      // Then, delete from the service table
      await supabase.from('service').delete().match({'service_id': serviceId});

      // Remove service from UI list if deletion is successful
      setState(() {
        services.removeWhere((s) => s['id'] == service['id']);
      });
    } catch (error) {
      // Show error dialog if deletion fails
      showErrorDialog(context, 'Failed to delete service: ${error.toString()}');
    }
  }

  Future<void> _fetchPackagesByCategory(String category) async {
    if (serviceProviderId == null) return;
    print("Fetching packages for category: $category");

    final response = await supabase
        .from('serviceprovider_package')
        .select('*, package!inner(package_name, price, package_image)')
        .eq('sp_id', serviceProviderId)
        // .eq('package_category', category);
        .filter('package.package_category', 'cs', '["$category"]');
    // .eq('package.package_category', category);
    // .contains('package.package_category', [category]);
    print("Raw response: $response");

    // Check if the response contains data
    if (response is List && response.isNotEmpty) {
      setState(() {
        packages = List<Map<String, dynamic>>.from(response.map((item) {
          return {
            'id': item['package_id'],
            'name': item['package']['package_name'] ?? 'Unknown',
            'price': item['package']['price'] ?? 0,
            'image': item['package']['package_image'] ??
                'assets/images/default_image.png', // Default image path
          };
        }));
      });
    } else {
      setState(() {
        packages = [];
      });
    }
  }

  Future<void> _createPackage(Map<String, dynamic> newPackage) async {
    final response = await supabase.from('serviceprovider_package').insert({
      'sp_id': serviceProviderId,
      'package_id': newPackage['package_id'],
      'package_category': [selectedCategory],
      'price': newPackage['price'],
    });

    if (response != null) {
      throw Exception('Failed to create package: ${response.message}');
    }
    await _fetchPackagesByCategory(selectedCategory!);
    setState(() {
      packages.add(newPackage);
    });
  }

  void _navigateToAddPackage(BuildContext context) async {
    if (serviceProviderId != null) {
      // Check if it's non-null
      final newPackage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddPackageScreen(
            packageProviderId: serviceProviderId!, // Pass non-null value
            packageCategory: selectedCategory,
          ),
        ),
      );

      if (newPackage != null) {
        await _createPackage(newPackage);
      }
    } else {
      showErrorDialog(context, "Service Provider ID is missing.");
    }
  }

  void _navigateToPackageDetails(
      BuildContext context, Map<String, dynamic> packageData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageDetails(packageData: packageData),
      ),
    );
  }

  Future<void> _fetchPackages() async {
    if (serviceProviderId == null) return;

    final response = await supabase
        .from('serviceprovider_package')
        .select(
            'package_id, package(package_name, price, package_image, size, availability_status, inclusions, pet_type, min_weight, max_weight, package_type)')
        .eq('sp_id', serviceProviderId);
    if (response is List && response.isNotEmpty) {
      setState(() {
        packages = List<Map<String, dynamic>>.from(response.map((item) {
          final package = item['package'];
          return {
            'id': item['package_id'], // Ensure you fetch the id
            'name': item['package']['package_name'] ?? 'Unknown',
            'price': item['package']['price'] ?? 0,
            'image': item['package']['package_image'] ??
                'assets/images/default_image.png',
            'sizes': item['package']['size'] ?? 0,
            'availability': (package['availability_status'] is bool)
                ? (package['availability_status'] ? 'Available' : 'Unavailable')
                : package['availability_status'] ?? 'Unknown',
            'inclusions': (package['inclusions'] as List).join(', '),
            'pets': (package['pet_type'] as List).join(', '),
            'minWeight': item['package']['min_weight'] ?? 0,
            'maxWeight': item['package']['max_weight'] ?? 0,
            'type': (package['package_type'] as List).join(', '),
          };
        }));
      });
    } else {
      setState(() {
        packages = [];
      });
    }
  }

// Delete package from Supabase
  Future<void> _deletePackage(Map<String, dynamic> package) async {
    final packageId = package['id'];

    print("Deleting package with ID: $package['id']");
    print("Service Provider ID: $serviceProviderId");
    try {
      // First, delete from the bridge table
      await supabase
          .from('serviceprovider_package')
          .delete()
          .match({'sp_id': serviceProviderId, 'package_id': packageId});

      // Then, delete from the package table
      await supabase.from('package').delete().match({'package_id': packageId});

      // Remove package from UI list if deletion is successful
      setState(() {
        packages.removeWhere((p) => p['id'] == package['id']);
      });
    } catch (error) {
      // Show error dialog if deletion fails
      showErrorDialog(context, 'Failed to delete package: ${error.toString()}');
    }
  }

  // Method to show delete dialog
  void _showDeleteDialog(
      BuildContext context, Map<String, dynamic> item, bool isService) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        service: item,
        onDelete: () async {
          if (isService) {
            await _deleteService(item); // Call service deletion
          } else {
            await _deletePackage(item); // Call package deletion
          }
          if (mounted) {
            Navigator.pop(context); // Close dialog after deletion
          }
        },
      ),
    );
  }

  // Method to show a modal to select category

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pet Grooming'),
              onTap: () {
                setState(() {
                  selectedCategory = 'pet grooming';
                });
                Navigator.pop(context);
                _fetchServicesByCategory('pet grooming');
                _fetchPackagesByCategory('pet grooming'); // Fetch packages too
              },
            ),
            ListTile(
              title: const Text('Pet Boarding'),
              onTap: () {
                setState(() {
                  selectedCategory = 'pet boarding';
                });
                Navigator.pop(context);
                _fetchServicesByCategory('pet boarding');
                _fetchPackagesByCategory('pet boarding'); // Fetch packages too
              },
            ),
            ListTile(
              title: const Text('Veterinary Service'),
              onTap: () {
                setState(() {
                  selectedCategory = 'veterinary service';
                });
                Navigator.pop(context);
                _fetchServicesByCategory('veterinary service');
                _fetchPackagesByCategory(
                    'veterinary service'); // Fetch packages t
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchServicesByCategory(String category) async {
    if (serviceProviderId == null) return;

    final response = await supabase
        .from('serviceprovider_service')
        .select(
            '*, service!inner(service_name, price, service_image, service_category)')
        .eq('sp_id', serviceProviderId)
        .filter('service.service_category', 'cs', '["$category"]');

    if (response is List && response.isNotEmpty) {
      setState(() {
        services = List<Map<String, dynamic>>.from(response.map((item) {
          return {
            'name': item['service']['service_name'] ?? 'Unknown',
            'price': item['service']['price'] ?? 0,
            'image': item['service']['service_image'] ??
                'assets/images/default_image.png', // Default image path
          };
        }));
      });
    } else {
      setState(() {
        services = []; // Clear services if none found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator when loading is true
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        selectedCategory ?? 'pet grooming', // Dynamic text
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(160, 62, 6, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () => _showCategoryModal(context),
                        child: const Text(
                          "• Edit Category",
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Services",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                // Display added services in card form
                services.isEmpty
                    ? const Center(
                        child: Text('No services added for this category.'))
                    : Column(
                        children: services.map((service) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              children: [
                                // The card displaying service information
                                Expanded(
                                  child: Card(
                                    margin: const EdgeInsets.only(
                                        right:
                                            10), // To give some space between card and icon
                                    child: ListTile(
                                      leading: service['image'] != null &&
                                              service['image'].isNotEmpty
                                          ? Image.network(
                                              service['image'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.image, size: 50),
                                      title: Text(
                                          service['name'] ?? 'Unknown Name'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('₱${service['price'] ?? 'N/A'}'),
                                        ],
                                      ),
                                      onTap: () async {
                                        _navigateToServiceDetails(
                                            context, service);
                                      },

                                      //   // If service was edited, update the list
                                      //   if (updatedService != null) {
                                      //     setState(() {
                                      //       int index = services.indexWhere((service) =>
                                      //           service['id'] == updatedService['id']);
                                      //       if (index != -1) {
                                      //         services[index] = updatedService;
                                      //       } // Update with edited service
                                      //     });
                                      //   }
                                      // },
                                    ),
                                  ),
                                ),
                                // The trash icon outside the card
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _showDeleteDialog(
                                        context, service, true)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 20),
                // Centered Add More button
                if (selectedCategory != 'All services')
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _navigateToAddService(context),
                      child: const Text('Add a service'),
                    ),
                  ),

                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Packages",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                // Display added packages in card form
                packages.isEmpty
                    ? const Center(
                        child: Text('No packages added for this category.'))
                    : Column(
                        children: packages.map((package) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              children: [
                                // The card displaying package information
                                Expanded(
                                  child: Card(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: ListTile(
                                      leading: package['image'] != null &&
                                              package['image'].isNotEmpty
                                          ? Image.network(
                                              package['image'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(Icons.image, size: 50),
                                      title: Text(
                                          package['name'] ?? 'Unknown Name'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('₱${package['price'] ?? 'N/A'}'),
                                        ],
                                      ),
                                      onTap: () async {
                                        _navigateToPackageDetails(
                                            context, package);
                                      },
                                    ),
                                  ),
                                ),
                                // The trash icon outside the card
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _showDeleteDialog(
                                        context, package, false)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 20),
                // Centered Add More button
                if (selectedCategory != 'All services')
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _navigateToAddPackage(context),
                      child: const Text('Add a package'),
                    ),
                  ),
              ],
            ),
    );
  }
}
