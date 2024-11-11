import 'package:flutter/material.dart';
import 'package:service_provider/Widgets/error_dialog.dart';
import 'package:service_provider/screens/add_package.dart';
import 'package:service_provider/screens/add_service.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';
import 'package:service_provider/screens/package_details.dart';
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
  bool _isLoading = false;

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
        .select('*, service(service_name, price, service_image)')
        .eq('sp_id', serviceProviderId);

    // Check if the response contains data
    if (response is List && response.isNotEmpty) {
      setState(() {
        services = List<Map<String, dynamic>>.from(response.map((item) {
          final service = item['service'];
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

  Future<void> _fetchPackages() async {
    if (serviceProviderId == null) return;

    final response = await supabase
        .from('serviceprovider_package')
        .select('*, package(package_name, price, package_image)')
        .eq('sp_id', serviceProviderId);
    if (response is List && response.isNotEmpty) {
      setState(() {
        packages = List<Map<String, dynamic>>.from(response.map((item) {
          return {
            'id': item['id'], // Ensure you fetch the id
            'name': item['package']['package_name'] ?? 'Unknown',
            'price': item['package']['price'] ?? 0,
            'image': item['package']['package_image'] ??
                'assets/images/default_image.png',
          };
        }));
      });
    } else {
      setState(() {
        packages = [];
      });
    }
  }

  // Method to navigate to the AddPackageScreen and get the new package
  void _navigateToAddPackage(BuildContext context) async {
    final updatedService = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPackageScreen(),
      ),
    );
    if (updatedService != null) {
      setState(() {
        packages.add(updatedService);
      });
    }
  }

  // Method to show delete dialog
  void _showDeleteDialog(
      BuildContext context, Map<String, dynamic> item, bool isService) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(
        service: item,
        onDelete: () {
          setState(() {
            if (isService) {
              services.remove(item);
            } else {
              packages.remove(item);
            }
          });
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchServicesByCategory(String category) async {
    setState(() {
      bool isloading = true;
    });
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
      body: _isLoading
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
                                      // onTap: () async {
                                      //   // Navigate to EditServiceScreen with the service data
                                      //   final updatedService = await Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) =>
                                      //           ServiceDetails(serviceData: service),
                                      //     ),
                                      //   );
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
                ...packages.map((package) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                              title: Text(package['name']),
                              // subtitle: Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              // Text(
                              //   package['description'] != null &&
                              //           package['description']!.length > 50
                              //       ? '${package['description'].substring(0, 50)}... See more'
                              //       : package['description'] ??
                              //           'No description available',
                              // ),
                              // const SizedBox(height: 5),
                              // const Text("Inclusions:"),
                              // if (package['inclusionList'] != null &&
                              //     package['inclusionList'] is List<String> &&
                              //     package['inclusionList'].isNotEmpty)
                              //   ...package['inclusionList']
                              //       .map<Widget>((pkg) => Text(pkg.toString()))
                              //       .toList()
                              // else
                              //   const Text("No inclusion specified"),
                              //   ],
                              // ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₱${package['price']}',
                                  ),
                                ],
                              ),
                              onTap: () async {
                                // Navigate to EditServiceScreen with the service data
                                final updatedPackage = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PackageDetails(packageData: package),
                                  ),
                                );
                                // If package was edited, update the list
                                if (updatedPackage != null) {
                                  setState(() {
                                    int index = packages.indexWhere((pkg) =>
                                        pkg['id'] == updatedPackage['id']);
                                    if (index != -1) {
                                      packages[index] = updatedPackage;
                                    } // Update with edited service });
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        // The trash icon outside the card
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showDeleteDialog(context, package, false),
                        ),
                      ],
                    ),
                  );
                }),
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
