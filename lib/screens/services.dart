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
  bool isLoading = true;

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

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('serviceprovider_service')
          .select(
              '''
              service_id,
              price,
              size,
              min_weight,
              max_weight,
              service(
                service_name,
                service_image,
                service_type,
                pet_type,
                availability_status
              )
              ''')
          .eq('sp_id', serviceProviderId);

      print("Supabase response: $response"); // Debugging response

      if (response is List && response.isNotEmpty) {
        setState(() {
          services = response.map((item) {
            final service = item['service'] as Map<String, dynamic>? ?? {};
            return {
              'id': item['service_id'] ?? 'N/A',
              'name': service['service_name'] ?? 'Unknown',
              'price': item['price'] ?? 0,
              'image': (service['service_image'] ?? '').isNotEmpty
                  ? service['service_image']
                  : 'assets/images/default_image.png',
              'type': service['service_type'] is List
                  ? (service['service_type'] as List).join(', ')
                  : service['service_type'] ?? 'Unknown',
              'pets': service['pet_type'] is List
                  ? (service['pet_type'] as List).join(', ')
                  : service['pet_type'] ?? 'Unknown',
              'size': item['size'] ?? 'Unknown',
              'minWeight': item['min_weight'] ?? 0,
              'maxWeight': item['max_weight'] ?? 0,
              'availability': service['availability_status'] == true
                  ? 'Available'
                  : 'Unavailable',
            };
          }).toList();
        });
      } else {
        setState(() {
          services = [];
        });
      }
    } catch (error, stackTrace) {
      print("Error fetching services: $error");
      print("Stack trace: $stackTrace");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _createService(Map<String, dynamic> newService) async {
    try {
      // Prepare the service provider service data
      final serviceData = {
        'sp_id': serviceProviderId,
        'service_id': newService['service_id'],
        'size': newService['size'] ?? 'Unknown', // Ensure 'size' is included
        'price': newService['price'] ?? 0,
        'min_weight': newService['min_weight'] ?? 0, // Handle min_weight
        'max_weight': newService['max_weight'] ?? 0, // Handle max_weight
      };

      // Insert into the 'serviceprovider_service' table
      final response = await supabase.from('serviceprovider_service').insert(serviceData).select();
      
      if (response is List && response.isNotEmpty) {
        // Fetch services by category after successful insertion
        await _fetchServicesByCategory(selectedCategory!);

        setState(() {
          services.add({
            'id': response.first['service_id'],
            'name': newService['name'],
            'price': newService['price'],
            'size': newService['size'],
            'minWeight': newService['min_weight'],
            'maxWeight': newService['max_weight'],
            'category': selectedCategory,
          });
        });
      } else {
        throw Exception('Failed to create service. Response: $response');
      }
    } catch (error) {
      print("Error creating service: $error");
      throw Exception('Error creating service: $error');
    }
  }


  void _navigateToAddService() async {
    final newService = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddServiceScreen(
          serviceProviderId: serviceProviderId!,
          serviceCategory: selectedCategory,
          serviceData: {}, // Pass additional data if needed
        ),
      ),
    );

    if (newService != null) {
      setState(() {
        services.add(newService);
      });
    }
  }

  void _navigateToServiceDetails(
      BuildContext context, Map<String, dynamic> serviceData) {
    if (serviceProviderId == null) {
      print("Error: Service Provider ID is null. Unable to navigate.");
      return; // Prevent navigation if the ID is missing
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetails(
          serviceProviderId:
              serviceProviderId!, // Safely pass the non-null value
          serviceData: serviceData, // Passing the service data
        ),
      ),
    );
  }
// Delete service from Supabase

  Future<void> _deleteService(Map<String, dynamic> service) async {
    final serviceId = service['id'];
    final imageUrl = service['image'];

    print("Deleting service with ID: $service['id']");
    print("Service Provider ID: $serviceProviderId");
    if (serviceId == null) {
      showErrorDialog(context, 'Failed to delete service: Invalid service ID');
      return;
    }

    try {
      // Delete the image from the bucket (if URL exists)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final fileName =
            imageUrl.split('/').last; // Get the file name from the URL
        // final filePath =
        //     'service_images/$fileName'; // Construct the full path for service images
        final filePath = fileName;

        final response = await supabase.storage
            .from('service_provider_images')
            .remove([filePath]);
        print("Image deleted from the bucket successfully.");
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

  // Fetch packages from the service_package_with_category view
  final response = await supabase
      .from('service_package_with_category')
      .select('*')
      .eq('sp_id', serviceProviderId) // Filter by service provider ID
      .eq('category_name', category); // Filter by category name

  // Debug output to check the response
  print("Response from service_package_with_category: $response");

  // Check if the response is valid and contains data
  if (response is List && response.isNotEmpty) {
    print("Fetched packages: ${response.length} packages found.");
    setState(() {
      packages = List<Map<String, dynamic>>.from(response.map((item) {
        return {
          'id': item['serviceprovider_package_id'],
          'name': item['package_name'] ?? 'Unknown',
          'price': item['price'] ?? 0,
          'image': item['package_image'] ??
              'assets/images/default_image.png',
          'sizes': item['size'] ?? 'Unknown',
          'availability': (item['availability_status'] is bool)
              ? (item['availability_status'] ? 'Available' : 'Unavailable')
              : item['availability_status'] ?? 'Unknown',
          'inclusions': (item['inclusions'] as List).join(', '),
          'pets': (item['pet_type'] as List).join(', '),
          'minWeight': item['min_weight'] ?? 0,
          'maxWeight': item['max_weight'] ?? 0,
          'type': (item['package_type'] as List).join(', '),
          'category': item['category_name'] ?? 'Unknown',
        };
      }));
    });
  } else {
    print("No packages found or the response is empty.");
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
            packageData: {},
          ),
        ),
      );

      if (newPackage != null) {
        setState(() {
          packages.add(newPackage);
        });
      }
    } else {
      showErrorDialog(context, "Service Provider ID is missing.");
    }
  }

  void _navigateToPackageDetails(
      BuildContext context, Map<String, dynamic> packageData) {
    if (serviceProviderId == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PackageDetails(
            serviceProviderId: serviceProviderId!, packageData: packageData),
      ),
    );
  }

Future<void> _fetchPackages() async {
  if (serviceProviderId == null) return;

  setState(() {
    isLoading = true;
  });

  try {
    final response = await supabase
        .from('serviceprovider_package')
        .select(
            '''
            serviceprovider_package_id,
            price,
            size,
            min_weight,
            max_weight,
            package_id,
            package(
              package_name,
              package_image,
              availability_status,
              package_category,
              package_type,
              pet_type
            ),
            service_package_category(
              category_name
            )
            ''')
        .eq('sp_id', serviceProviderId);

    print("Supabase response: $response"); // Debugging output

    if (response is List && response.isNotEmpty) {
      setState(() {
        packages = response.map((item) {
          final package = item['package'] as Map<String, dynamic>? ?? {};
          final category = item['service_package_category'] as Map<String, dynamic>? ?? {};

          return {
            'id': item['serviceprovider_package_id'] ?? 'N/A',
            'name': package['package_name'] ?? 'Unknown',
            'price': item['price'] ?? 0,
            'image': (package['package_image'] ?? '').isNotEmpty
                ? package['package_image']
                : 'assets/images/default_image.png',
            'size': item['size'] ?? 'Unknown',
            'availability': package['availability_status'] == true
                ? 'Available'
                : 'Unavailable',
            'category': category['category_name'] ?? 'Unknown',
            'pets': package['pet_type'] is List
                ? (package['pet_type'] as List).join(', ')
                : package['pet_type'] ?? 'Unknown',
            'minWeight': item['min_weight'] ?? 0,
            'maxWeight': item['max_weight'] ?? 0,
            'type': package['package_type'] is List
                ? (package['package_type'] as List).join(', ')
                : package['package_type'] ?? 'Unknown',
          };
        }).toList();
      });
    } else {
      setState(() {
        packages = [];
      });
    }
  } catch (error, stackTrace) {
    print("Error fetching packages: $error");
    print("Stack trace: $stackTrace");
  } finally {
    setState(() {
      isLoading = false;
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
    if (serviceProviderId == null) {
      print("No service provider ID provided.");
      return;
    }

    // Fetch services from the service_with_category view
    final response = await supabase
        .from('service_with_category')
        .select('*')
        .eq('sp_id', serviceProviderId) // Filter by service provider ID
        .eq('category_name', category); // Filter by category name

    print("Response from service_with_category: $response");

    if (response is List && response.isNotEmpty) {
      print("Fetched services: ${response.length} services found.");
      setState(() {
        services = List<Map<String, dynamic>>.from(response.map((item) {
          return {
            'id': item['serviceprovider_service_id'],
            'name': item['service_name'] ?? 'Unknown',
            'price': item['price'] ?? 0,
            'size': item['size'] ?? 'Unknown',
            'minWeight': item['min_weight'] ?? 0,
            'maxWeight': item['max_weight'] ?? 0,
            'image': item['service_image'] ?? 'assets/images/default_image.png',
            'description': item['service_desc'] ?? 'No description available',
            'availability': item['availability_status'] != null
                ? (item['availability_status'] ? 'Available' : 'Unavailable')
                : 'Unknown',
            'type': item['service_type'] != null && item['service_type'] is List
                ? (item['service_type'] as List).join(', ')
                : item['service_type'] ?? 'Unknown',
            'pets': item['pet_type'] != null && item['pet_type'] is List
                ? (item['pet_type'] as List).join(', ')
                : item['pet_type'] ?? 'Unknown',
            'category': item['category_name'] ?? 'Unknown',
          };
        }));
      });
    } else {
      print("No services found or the response is empty.");
      setState(() {
        services = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Show loading indicator when loading is true
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern styled instruction box
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color.fromRGBO(160, 62, 6, 1),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Tap on 'Edit Category' to start adding services or packages.",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          height:
                              16), // Spacer between instruction and category
                      Row(
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
                                          Text(
                                            service['price'] != null
                                                ? '₱${service['price']}' // Format price to 2 decimal places
                                                : '₱N/A', // Fallback if price is null
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        _navigateToServiceDetails(
                                            context, service);
                                      },
                                    ),
                                  ),
                                ),
                                // The trash icon outside the card
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _showDeleteDialog(context, service, true),
                                ),
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
                      onPressed: () => _navigateToAddService(),
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
                                      context, package, false),
                                ),
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