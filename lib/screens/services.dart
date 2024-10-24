import 'package:flutter/material.dart';
import 'package:service_provider/screens/add_package.dart';
import 'package:service_provider/screens/edit_service.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => ServicesScreenState();
}

class ServicesScreenState extends State<ServicesScreen> {
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> packages = [];
  String? selectedCategory = 'Pet Grooming'; // Default selected category

  // Method to navigate to the AddServiceScreen and get the new service
  void _navigateToAddService(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditServiceScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        services.add(result);
      });
    }
  }

  // Method to navigate to the AddPackageScreen and get the new package
  void _navigateToAddPackage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPackageScreen(),
      ),
    );
    if (result != null) {
      setState(() {
        packages.add(result);
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
              },
            ),
            ListTile(
              title: const Text('Pet Boarding'),
              onTap: () {
                setState(() {
                  selectedCategory = 'Pet Boarding';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Veterinary'),
              onTap: () {
                setState(() {
                  selectedCategory = 'Veterinary';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
                        subtitle: Text(service['description']),
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
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditServiceScreen(serviceData: service),
                            ),
                          );
                          // If service was edited, update the list
                          if (result != null) {
                            setState(() {
                              int index = services.indexOf(service);
                              packages[index] =
                                  result; // Update with edited service
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
                  // The card displaying service information
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(
                          right:
                              10), // To give some space between card and icon
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
                        subtitle: Text(package['description']),
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
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditServiceScreen(serviceData: package),
                            ),
                          );
                          // If service was edited, update the list
                          if (result != null) {
                            setState(() {
                              int index = services.indexOf(package);
                              services[index] =
                                  result; // Update with edited service
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
