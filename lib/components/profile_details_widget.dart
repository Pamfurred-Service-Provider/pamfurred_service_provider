import 'package:flutter/material.dart';

class ProfileDetailsWidget extends StatelessWidget {
  final Map<String, dynamic>? profileData;

  const ProfileDetailsWidget({Key? key, required this.profileData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("Opening Time:", profileData?['time_open']),
          const SizedBox(height: 10),
          _buildDetailRow("Closing Time:", profileData?['time_close']),
          // More details...
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(value ?? 'N/A',
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
      ],
    );
  }
}
