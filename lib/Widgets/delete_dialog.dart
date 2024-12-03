import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onDelete;

  const DeleteDialog({
    required this.service,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Service'),
      content: const Text('Are you sure you want to delete this service?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete(); // Trigger the delete callback
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class ShowDeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onDelete;

  const ShowDeleteDialog({
    required this.title,
    required this.content,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),  // Use the dynamic title
      content: Text(content),  // Use the dynamic content
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onDelete(); // Trigger the delete callback
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}