import 'package:flutter/material.dart';
import 'package:service_provider/Widgets/error_dialog.dart';
import 'package:service_provider/screens/add_package.dart';
import 'package:service_provider/screens/edit_service.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';
import 'package:service_provider/screens/service_details.dart';
import 'package:service_provider/screens/package_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> packages = [];
  String? selectedCategory = 'Pet Grooming'; // Default selected category

  // Method to navigate to the AddServiceScreen and get the new service
  void _navigateToAddService(BuildContext context) async {
    final updatedService = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditServiceScreen(),
      ),
    );

    if (updatedService != null) {
      setState(() {
        services.add(updatedService);
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
                  selectedCategory = 'Pet Grooming';
                });
                Navigator.pop(context);
                _fetchServicesByCategory('Pet Grooming');
              },
            ),
            ListTile(
              title: const Text('Pet Boarding'),
              onTap: () {
                setState(() {
                  selectedCategory = 'Pet Boarding';
                });
                Navigator.pop(context);
                _fetchServicesByCategory('Pet Boarding');
              },
            ),
            ListTile(
              title: const Text('Veterinary Care'),
              onTap: () {
                setState(() {
                  selectedCategory = 'Veterinary';
                });
                Navigator.pop(context);
                _fetchServicesByCategory('Veterinary');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchServicesByCategory(String category) async {
    final response = await supabase
        .from('service')
        .select()
        .contains('service_category', [category]); // Filter by category

    if (response.error == null) {
      setState(() {
        services = List<Map<String, dynamic>>.from(response.data);
      });
    } else {
      showErrorDialog(context, "Failed to fetch services");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  selectedCategory ?? 'Pet Grooming', // Dynamic text
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
          ...services.map((service) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  // The card displaying service information
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(
                          right:
                              10), // To give some space between card and icon
                      child: ListTile(
                        leading: service['image'] != null
                            ? Image.file(
                                service['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(service['name']),
                        subtitle: Text(
                          service['description'].length > 50
                              ? '${service['description'].substring(0, 50)}... See more'
                              : service['description'],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₱${service['price']}',
                            ),
                          ],
                        ),
                        onTap: () async {
                          // Navigate to EditServiceScreen with the service data
                          final updatedService = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceDetails(serviceData: service),
                            ),
                          );
                          // If service was edited, update the list
                          if (updatedService != null) {
                            setState(() {
                              int index = services.indexWhere((service) =>
                                  service['id'] == updatedService['id']);
                              if (index != -1) {
                                services[index] = updatedService;
                              } // Update with edited service
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
                          _showDeleteDialog(context, service, true)),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          // Centered Add More button
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  // The card displaying package information
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(right: 10),
                      child: ListTile(
                        leading: package['image'] != null
                            ? Image.file(
                                package['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image, size: 50),
                        title: Text(package['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package['description'] != null &&
                                      package['description'].length > 50
                                  ? '${package['description'].substring(0, 50)}... See more'
                                  : package['description'] ?? '',
                            ),
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
                          ],
                        ),
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
                              int index = packages.indexWhere(
                                  (pkg) => pkg['id'] == updatedPackage['id']);
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
                    onPressed: () => _showDeleteDialog(context, package, false),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          // Centered Add More button
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
