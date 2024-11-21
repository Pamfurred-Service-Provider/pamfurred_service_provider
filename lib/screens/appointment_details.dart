import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/components/date_and_time_formatter.dart';

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
        .update({'appointment_status': status}).eq(
            'appointment_id', widget.appointment['appointment_id']);

    if (response != null) {
      print('Error updating appointment status: ${response.message}');
    } else {
      widget
          .updateStatus(status); // Notify the parent widget (appointments.dart)
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.appointment['services'] as List<dynamic>;
    final packages = widget.appointment['packages'] as List<dynamic>;
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
            Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(160, 62, 6, 1)),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  style: const TextStyle(
                      fontSize: 18, color: Color.fromRGBO(160, 62, 6, 1)),
                  underline: Container(),
                  items: statusOptions
                      .map<DropdownMenuItem<String>>((String value) {
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
                      await updateAppointmentStatus(
                          newValue); // Update in Supabase
                    }
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Appointment Details Sections
            const Center(
              child: Text(
                'Appointment ID:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),

            // Appointment ID value section
            Center(
              child: buildDetailSection(
                '',
                '${widget.appointment['appointment_id'] ?? 'N/A'}',
              ),
            ),
            // Pet and Owner Details
            const SizedBox(height: 15),
            const Text(
              "Pet Owner Details:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            buildDetailSection('Name:',
                '${widget.appointment['pet_owner_first_name']} ${widget.appointment['pet_owner_last_name'] ?? ''}'),
            if (widget.appointment['appointment_type'] == 'Home service') ...[
              buildDetailSection('Address:',
                  '${widget.appointment['appointment_address'] ?? ''}'),
            ],
            buildDetailSection('Contact Number:',
                '${widget.appointment['pet_owner_phone_number'] ?? ''}'),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Pet Details:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildDetailSection(
                'Pet Name:', '${widget.appointment['pet_name'] ?? 'N/A'}'),
            buildDetailSection(
                'Pet Type:', '${widget.appointment['pet_type'] ?? 'N/A'}'),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Appointment Schedule:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildDetailSection(
              'Date:',
              formatDateToShort(
                  widget.appointment['appointment_date'] ?? 'N/A'),
            ),
            buildDetailSection(
              'Time:',
              formatTime(widget.appointment['appointment_time'] ?? 'N/A'),
            ),
            const SizedBox(height: 10),
            buildDetailSection('Service Type',
                '${widget.appointment['appointment_type'] ?? 'N/A'}'),
            const Divider(),
            const SizedBox(height: 10),
            const Row(
              children: [
                Text(
                  "Services and Packages Availed: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  'Price:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Services Availed
            if (services.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: services.map<Widget>((service) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            service['name'] ?? 'Service Name',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '₱ ${service['price'] ?? '0.0'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Packages Availed
            if (packages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: packages.map<Widget>((pkg) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pkg['name'] ?? 'Package Name',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '₱ ${pkg['price'] ?? '0.0'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 10),

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
                  '₱ ${widget.appointment['total_amount'] ?? ''}',
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
