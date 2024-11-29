import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/Supabase/service_backend.dart';
import 'services.dart';

class UpdateServiceScreen extends StatefulWidget {
  final String serviceProviderId;
  final String serviceId; // Added serviceId to update an existing service
  final Map<String, dynamic> serviceData; // Data to pre-fill the form

  const UpdateServiceScreen({
    super.key,
    required this.serviceProviderId,
    required this.serviceId,
    required this.serviceData, required serviceCategory,
  });

  @override
  State<UpdateServiceScreen> createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController minWeightController = TextEditingController();
  final TextEditingController maxWeightController = TextEditingController();
  final TextEditingController petsToCaterController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<String> petsList = [];
  bool _isLoading = false;

@override
void initState() {
  super.initState();

  print(widget.serviceData); // Print the entire map
  print(widget.serviceData['service_name']);
  
  // Pre-fill fields with data from serviceData
  nameController.text = widget.serviceData['service_name']?.toString() ?? '';
  priceController.text = widget.serviceData['price']?.toString() ?? '';
  minWeightController.text = widget.serviceData['min_weight']?.toString() ?? '';
  maxWeightController.text = widget.serviceData['max_weight']?.toString() ?? '';
  petsList = (widget.serviceData['pets_to_cater'] as List<dynamic>?)
      ?.map((e) => e.toString())
      .toList() ?? [];

  // Handle image URL
  if (widget.serviceData['image_url'] != null) {
    // Note: Ensure `_image` is only used for picked images, as File expects a valid path.
    // For prefilled image URLs, you might want to handle them separately as network images.
  }
}

  // Method to pick an image from the gallery
  Future<void> changeImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update the state with the selected image
      });
    }
  }

  // Method to add pet to the list
  void addPet() {
    List<String> availablePets = petType.where((pet) => !petsList.contains(pet)).toList();
    if (availablePets.isNotEmpty) {
      setState(() {
        petsList.add(availablePets.first);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All pets have been added.')));
    }
  }

  // Method to remove a pet from the list
  void _removePet(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: const Text('Are you sure you want to delete this?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => petsList.removeAt(index)); // Remove pet
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Static data for pet sizes
  List<String> sizeOptions = ['S', 'M', 'L', 'XL', 'N/A'];
  final List<String> petType = ['dog', 'cat', 'bunny'];
  String? serviceType = 'In-clinic';
  String? availability = 'Available';
  String? sizes = 'S';
  

  void _updateService() async {
    final backend = ServiceBackend();
    setState(() {
      _isLoading = true;
    });

    try {
      int price = int.tryParse(priceController.text) ?? 0;
      int minWeight = int.tryParse(minWeightController.text) ?? 0;
      int maxWeight = int.tryParse(maxWeightController.text) ?? 0;

      if (nameController.text.isEmpty || priceController.text.isEmpty || sizes == null) {
        throw Exception('Please fill all fields');
      }

      String imageUrl = '';
      if (_image != null) {
        imageUrl = await backend.uploadImage(_image!);
      } else if (widget.serviceData['service_image'] != null) {
        imageUrl = widget.serviceData['service_image'] ?? '';
      }

      await backend.updateService(
        serviceId: widget.serviceId,
        updatedData: {
          'service_name': nameController.text,
          'price': price,
          'size': sizes,
          'min_weight': minWeight,
          'max_weight': maxWeight,
          'pet_type': petsList,
          'service_type': [serviceType],
          'availability_status': availability == 'Available',
          'service_image': imageUrl,
        },
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ServicesScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service Updated Successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Service"),
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
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    image: DecorationImage(
                      image: _image == null
                          ? const AssetImage('assets/pamfurred_secondarylogo.png')
                          : FileImage(_image!) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: changeImage,
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
          const SizedBox(height: 20),
          const Text("Service Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextField(
            textCapitalization: TextCapitalization.words,
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Enter service name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Pet Specific Service", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ...petsList.asMap().entries.map((entry) {
            int index = entry.key;
            String pet = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: pet,
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              petsList[index] = newValue!;
                            });
                          },
                          items: petType
                              .where((petCategory) => !petsList.contains(petCategory) || petCategory == pet)
                              .map((petCategory) => DropdownMenuItem<String>(
                                    value: petCategory,
                                    child: Text(petCategory),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removePet(index),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: addPet,
            icon: const Icon(Icons.add),
            label: const Text("Add More"),
          ),
          const SizedBox(height: 10),
          const Text("Availability", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: availability,
                onChanged: (newValue) {
                  setState(() {
                    availability = newValue;
                  });
                },
                items: ['Available', 'Unavailable'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Pet Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: sizes,
                onChanged: (newValue) {
                  setState(() {
                    sizes = newValue;
                  });
                },
                items: sizeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          TextField(
            controller: priceController,
            decoration: const InputDecoration(
              hintText: "Enter price",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          const Text("Weight Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minWeightController,
                  decoration: const InputDecoration(
                    hintText: "Min weight",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: maxWeightController,
                  decoration: const InputDecoration(
                    hintText: "Max weight",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Service Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: serviceType,
                onChanged: (newValue) {
                  setState(() {
                    serviceType = newValue;
                  });
                },
                items: ['In-clinic', 'Home Service'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _updateService,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Update Service'),
          ),
        ],
      ),
    );
  }
}
