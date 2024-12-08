import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/Widgets/error_dialog.dart';
import 'package:service_provider/components/screen_transitions.dart';
import 'package:service_provider/providers/package_details_provider.dart';
import 'package:service_provider/providers/service_details_provider.dart';
import 'package:service_provider/providers/sp_details_provider.dart';
import 'package:service_provider/screens/add_package.dart';
import 'package:service_provider/screens/add_service.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';
import 'package:service_provider/screens/package_details.dart';
import 'package:service_provider/screens/service_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => ServicesScreenState();
}

class ServicesScreenState extends ConsumerState<ServicesScreen> {
  final supabase = Supabase.instance.client;
  String? serviceProviderId; // Nullable to allow dynamic assignment
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> packages = [];
  String? selectedCategory = 'All'; // Default selected category
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    setState(() {
      isLoading = true;
    });

    try {
      final serviceSession = supabase.auth.currentSession;
      if (serviceSession == null) {
        throw Exception("User not logged in");
      }

      final spId = serviceSession.user.id;
      print('Service provider ID: $userId');

      // Fetch the service provider ID (sp_id) using user_id
      final spResponse = await supabase
          .from('service_provider')
          .select('sp_id')
          .eq('sp_id', userId)
          .single();

      if (spResponse == null || spResponse['sp_id'] == null) {
        throw Exception("Service provider ID not found for user");
      }

      // Assign the retrieved sp_id
      serviceProviderId = spResponse['sp_id'];
      print('Service Provider ID: $serviceProviderId');

      // Fetch the services and packages
      await _fetchCategoryData(selectedCategory!, spId);
    } catch (e) {
      print('Error during session initialization: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
    final serviceSession = supabase.auth.currentSession;
    if (serviceSession == null) {
      throw Exception("User not logged in");
    }

    final spId = serviceSession.user.id;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () async {
                Navigator.pop(context);
                await _fetchCategoryData(
                    'All', spId); // Fetch services for "All"
              },
            ),
            ListTile(
              title: const Text('Pet Grooming'),
              onTap: () async {
                Navigator.pop(context);
                await _fetchCategoryData('pet grooming', spId);
              },
            ),
            ListTile(
              title: const Text('Pet Boarding'),
              onTap: () async {
                Navigator.pop(context);
                await _fetchCategoryData('pet boarding', spId);
              },
            ),
            ListTile(
              title: const Text('Veterinary Service'),
              onTap: () async {
                Navigator.pop(context);
                await _fetchCategoryData('veterinary service', spId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchCategoryData(String category, String spId) async {
    setState(() {
      selectedCategory = category;
    });

    try {
      // Fetch services for the selected category
      final fetchedServices = await fetchServicesByCategory(category, spId);
      print("response for fetched services w/ filter: $fetchedServices");
      setState(() {
        services =
            fetchedServices; // Update your state with the fetched services
      });

      // // Fetch packages for the selected category
      final fetchedPackages = await fetchPackagesByCategory(category, spId);
      print("response for fetched packages w/ filter: $fetchedPackages");
      setState(() {
        packages = fetchedPackages; // Assuming you have a variable for packages
      });
    } catch (e) {
      // Handle any errors
      print('Error fetching data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchServicesByCategory(
      String category, String s) async {
    final serviceSession = supabase.auth.currentSession;
    if (serviceSession == null) {
      throw Exception("User not logged in");
    }

    final spId = serviceSession.user.id;
    final response = await Supabase.instance.client.rpc(
        'fetch_services_by_category',
        params: {'category': category, 'sp_id_param': spId});

    // Return the data as a list of maps
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchPackagesByCategory(
      String category, String s) async {
    final serviceSession = supabase.auth.currentSession;
    if (serviceSession == null) {
      throw Exception("User not logged in");
    }

    final spId = serviceSession.user.id;
    final response = await Supabase.instance.client.rpc(
        'fetch_packages_by_category',
        params: {'category': category, 'sp_id_param': spId});

    // Return the data as a list of maps
    return (response as List).cast<Map<String, dynamic>>();
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
                                      leading: SizedBox(
                                        width: 50,
                                        child: service['service_image'] !=
                                                    null &&
                                                service['service_image']
                                                    .isNotEmpty &&
                                                service['service_image']
                                                    .startsWith('http')
                                            ? Image.network(
                                                service['service_image'],
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                service['service_image']
                                                            ?.isNotEmpty ??
                                                        false
                                                    ? service['service_image']
                                                    : 'assets/pamfurred_secondarylogo.png',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      title: Text(service['service_name'] ??
                                          'Unknown Name'),
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
                                        // Set the service ID in the Riverpod provider
                                        ref
                                            .read(selectedServiceIdProvider
                                                .notifier)
                                            .state = service['service_id'];

                                        // Navigate to the ServiceDetailsScreen
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ServiceDetails()),
                                        );
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
                if (selectedCategory != 'All')
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
                                      leading:
                                          package['package_image'] != null &&
                                                  package['package_image']
                                                      .isNotEmpty &&
                                                  package['package_image']
                                                      .startsWith('http')
                                              ? Image.network(
                                                  package['package_image'],
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  package['package_image']
                                                              ?.isNotEmpty ??
                                                          false
                                                      ? package['package_image']
                                                      : 'assets/pamfurred_secondarylogo.png',
                                                  fit: BoxFit.cover,
                                                ),
                                      title: Text(package['package_name'] ??
                                          'Unknown Name'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('₱${package['price'] ?? 'N/A'}'),
                                        ],
                                      ),
                                      onTap: () async {
                                        print(
                                            "Package map: $package"); // Print the whole service map

                                        print(
                                            "Selected Package ID: ${package['package_id']}");

                                        // Set the service ID in the Riverpod provider
                                        ref
                                            .read(selectedPackageIdProvider
                                                .notifier)
                                            .state = package['package_id'];

                                        // Navigate to the ServiceDetailsScreen
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PackageDetails()),
                                        );
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
                if (selectedCategory != 'All')
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
