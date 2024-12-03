import 'package:flutter/material.dart';

class RemovePetTypeDialog extends StatelessWidget {
  final Map<String, dynamic> petsList;
  final VoidCallback onDelete;

  const RemovePetTypeDialog({
    required this.petsList,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Pet Type'),
      content: const Text('Are you sure you want to delete this pet type?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close dialog
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete(); // Call onDelete callback
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
