import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final Function(String) updateStatus;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
    required this.updateStatus,
  });

  @override
  AppointmentDetailScreenState createState() => AppointmentDetailScreenState();
}

class AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late String dropdownValue;
  final List<String> statusOptions = ['Done', 'Cancelled', 'Upcoming'];
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.appointment['appointment_status'];
  }

  // Function to update the appointment status in Supabase
  Future<void> updateAppointmentStatus(String status) async {
    final response = await supabase
        .from('appointment')
        .update({'appointment_status': status})
        .eq('appointment_id', widget.appointment['appointment_id']);
    
    if (response.error != null) {
      print('Error updating appointment status: ${response.error!.message}');
    } else {
      widget.updateStatus(status); // Notify the parent widget (appointments.dart)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, dropdownValue); // Pass back updated status
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            // Establishment Name
            Center(
              child: Text(
                "${widget.appointment['establishment_name'] ?? 'Establishment'}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Appointment Status Section with Dropdown
            const Text(
              'Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: dropdownValue,
              items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null && newValue != dropdownValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                  await updateAppointmentStatus(newValue); // Update in Supabase
                }
              },
            ),
            const SizedBox(height: 10),

            // Appointment Details Sections
            buildDetailSection('Appointment ID', '${widget.appointment['appointment_id'] ?? 'N/A'}'),
            buildDetailSection('Date', '${widget.appointment['appointment_date'] ?? 'N/A'}'),
            buildDetailSection('Time', '${widget.appointment['appointment_time'] ?? 'N/A'}'),
            buildDetailSection('Address', '${widget.appointment['appointment_address'] ?? 'N/A'}'),
            buildDetailSection('Type', '${widget.appointment['appointment_type'] ?? 'N/A'}'),

            const Divider(height: 20, color: Colors.grey),

            // Pet and Owner Details
            buildDetailSection('Pet Name', '${widget.appointment['pet_name'] ?? 'N/A'}'),
            buildDetailSection('Pet Owner', '${widget.appointment['pet_owner_first_name']} ${widget.appointment['pet_owner_last_name'] ?? ''}'),
            const Divider(height: 20, color: Colors.grey),

            // Services Availed
            const Text(
              'Services Availed:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            if (widget.appointment['services'] != null && widget.appointment['services'] is List)
              ...List<Widget>.generate(widget.appointment['services'].length, (index) {
                var service = widget.appointment['services'][index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${service['service_name'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '₱ ${service['service_price'] ?? '0.0'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 10),

            // Packages Availed
            const Text(
              'Packages Availed:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (widget.appointment['package_name'] != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.appointment['package_name']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Inclusions: ${widget.appointment['package_inclusions'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '₱ ${widget.appointment['package_price'] ?? '0.0'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Total Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(160, 62, 6, 1),
                  ),
                ),
                Text(
                  '₱ ${widget.appointment['total_amount'] ?? '0.0'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(160, 62, 6, 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
