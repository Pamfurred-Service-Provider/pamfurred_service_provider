import 'package:flutter/material.dart';

class AddNewPackageDialog extends StatefulWidget {
  final List<Map<String, String>>
      serviceNamesWithCategories; // Each map has service_name and category_name
  final List<String> selectedServices;
  final ValueChanged<List<String>> onServicesSelected;
  final ValueChanged<String> onNewServiceAdded;
  final String? packageCategory;
  final TextEditingController searchController;

  const AddNewPackageDialog({
    super.key,
    required this.serviceNamesWithCategories,
    required this.selectedServices,
    required this.onServicesSelected,
    required this.onNewServiceAdded,
    required this.packageCategory,
    required this.searchController,
  });

  @override
  _AddNewPackageDialogState createState() => _AddNewPackageDialogState();
}

class _AddNewPackageDialogState extends State<AddNewPackageDialog> {
  late List<Map<String, String>> filteredServices;
  late List<String> tempSelectedServices;
  bool isDropdownVisible = false;
  final FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    filteredServices =
        _filterServicesByCategory(widget.serviceNamesWithCategories);
    tempSelectedServices = List.from(widget.selectedServices);
    widget.searchController.addListener(_filterServices);
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isDropdownVisible = true;
        });
      } else {
        setState(() {
          isDropdownVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterServices);
    focusNode.dispose();
    super.dispose();
  }

  /// Filters services by package category
  List<Map<String, String>> _filterServicesByCategory(
      List<Map<String, String>> services) {
    if (widget.packageCategory == null || widget.packageCategory!.isEmpty) {
      return services;
    }
    return services
        .where((service) =>
            service['category_name']?.toLowerCase() ==
            widget.packageCategory!.toLowerCase())
        .toList();
  }

  /// Updates the filtered list based on the search query
  void _filterServices() {
    final query = widget.searchController.text.toLowerCase();
    final allServicesInCategory =
        _filterServicesByCategory(widget.serviceNamesWithCategories);

    setState(() {
      filteredServices = allServicesInCategory
          .where((service) =>
              service['service_name']?.toLowerCase().contains(query) ?? false)
          .toList();
      isDropdownVisible = filteredServices.isNotEmpty;
      if (query.isNotEmpty && filteredServices.isEmpty) {
        filteredServices = [
          {'service_name': 'Add New Service', 'category_name': ''}
        ]; // Show "Add New Service" option if no match found
      }
    });
  }

  /// Adds a new service to the list
  void _addNewService() {
    final newServiceName = widget.searchController.text.trim();
    if (newServiceName.isNotEmpty &&
        !widget.serviceNamesWithCategories.any((service) =>
            service['service_name']?.toLowerCase() ==
            newServiceName.toLowerCase())) {
      final newService = {
        'service_name': newServiceName,
        'category_name': widget.packageCategory ?? ''
      };
      setState(() {
        widget.serviceNamesWithCategories.add(newService);
        widget.onNewServiceAdded(newServiceName);
        widget.searchController.text = newServiceName;
        filteredServices = []; // Hide dropdown after adding the new service
        isDropdownVisible = false;
      });
    } else if (newServiceName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid service name'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This service already exists'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // behavior: HitTestBehavior.opaque,
      onTap: () {
        // Hide the dropdown when clicking outside of it
        FocusScope.of(context).unfocus();
        setState(() {
          filteredServices = [];
          isDropdownVisible = false;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.searchController,
            textCapitalization: TextCapitalization.words,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Search or Add Service',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.search),
            ),
            onChanged: (_) {
              _filterServices();
            },
          ),
          const SizedBox(height: 8),
          if (filteredServices.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    final serviceName = service['service_name']!;
                    return ListTile(
                      title: Row(
                        children: [
                          if (serviceName == 'Add New Service')
                            const Icon(Icons.add, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(serviceName),
                          ),
                          if (serviceName != 'Add New Service')
                            Checkbox(
                              value: tempSelectedServices.contains(serviceName),
                              onChanged: (bool? isChecked) {
                                setState(() {
                                  if (isChecked != null && isChecked) {
                                    tempSelectedServices.add(serviceName);
                                  } else {
                                    tempSelectedServices.remove(serviceName);
                                  }
                                  widget
                                      .onServicesSelected(tempSelectedServices);
                                });
                              },
                            ),
                        ],
                      ),
                      onTap: () {
                        if (serviceName == 'Add New Service') {
                          _addNewService();
                        } else {
                          setState(() {
                            if (tempSelectedServices.contains(serviceName)) {
                              // Remove the service if it is already selected
                              tempSelectedServices.remove(serviceName);
                            } else {
                              // Add the service if it is not selected
                              tempSelectedServices.add(serviceName);
                            }
                            // Notify the parent widget about the updated selection
                            widget.onServicesSelected(tempSelectedServices);
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
