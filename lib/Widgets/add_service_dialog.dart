import 'package:flutter/material.dart';

class AddServiceDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  AddServiceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Service'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Enter service name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Cancel action
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
                context, _controller.text.trim()); // Return new service name
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
