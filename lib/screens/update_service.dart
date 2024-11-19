import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_provider/Supabase/service_backend.dart';

class UpdateServiceScreen extends StatefulWidget {
  final Map<String, dynamic> serviceData;
  final String serviceProviderId;

  const UpdateServiceScreen({
    super.key,
    required this.serviceData,
    required this.serviceProviderId,
  });

  @override
  State<UpdateServiceScreen> createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  late TextEditingController serviceNameController;
  late TextEditingController priceController;
  late TextEditingController sizeController;
  late TextEditingController minWeightController;
  late TextEditingController maxWeightController;
  late TextEditingController petsController;
  late TextEditingController serviceTypeController;

  String? imageUrl;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    final data = widget.serviceData;

    serviceNameController = TextEditingController(text: data['name']);
    priceController = TextEditingController(text: data['price']?.toString());
    sizeController = TextEditingController(text: data['size']);
    minWeightController =
        TextEditingController(text: data['minWeight']?.toString());
    maxWeightController =
        TextEditingController(text: data['maxWeight']?.toString());
    petsController = TextEditingController(text: data['pets']);
    serviceTypeController = TextEditingController(text: data['type']);
    imageUrl = data['image'];
  }

  @override
  void dispose() {
    serviceNameController.dispose();
    priceController.dispose();
    sizeController.dispose();
    minWeightController.dispose();
    maxWeightController.dispose();
    petsController.dispose();
    serviceTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _updateService() async {
    try {
      final backend = ServiceBackend();

      // If a new image is selected, upload it
      String? newImageUrl;
      if (selectedImage != null) {
        newImageUrl = await backend.uploadImage(selectedImage!);

        // // Optional: Delete the old image from the bucket
        // if (imageUrl != null && imageUrl!.isNotEmpty) {
        //   await backend.deleteImage(imageUrl!);
        // }
      }

      // Update the service details
      final updatedServiceData = {
        'name': serviceNameController.text,
        'price': int.parse(priceController.text),
        'size': sizeController.text,
        'minWeight': int.parse(minWeightController.text),
        'maxWeight': int.parse(maxWeightController.text),
        'pets': petsController.text,
        'type': serviceTypeController.text,
        'image': newImageUrl ?? imageUrl,
      };

      await backend.updateService(
        serviceId: widget.serviceData['id'],
        updatedData: updatedServiceData,
      );

      Navigator.pop(context, updatedServiceData); // Return updated data
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update service: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: selectedImage != null
                    ? Image.file(
                        selectedImage!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : (imageUrl != null && imageUrl!.isNotEmpty
                        ? Image.network(
                            imageUrl!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, size: 200)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: serviceNameController,
              decoration: const InputDecoration(labelText: 'Service Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: sizeController,
              decoration: const InputDecoration(labelText: 'Size'),
            ),
            TextField(
              controller: minWeightController,
              decoration: const InputDecoration(labelText: 'Min Weight'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: maxWeightController,
              decoration: const InputDecoration(labelText: 'Max Weight'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: petsController,
              decoration: const InputDecoration(labelText: 'Pet Type'),
            ),
            TextField(
              controller: serviceTypeController,
              decoration: const InputDecoration(labelText: 'Service Type'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateService,
              child: const Text('Update Service'),
            ),
          ],
        ),
      ),
    );
  }
}
