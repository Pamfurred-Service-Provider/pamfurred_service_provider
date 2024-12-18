import 'package:flutter/material.dart';
import 'package:service_provider/Widgets/confirmation_dialog.dart';
import 'package:service_provider/components/date_and_time_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final List<String> appointmentStatus = ['Accept', 'Reject'];
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
    print('Appointment ID: ${widget.appointment['appointment_id']}');

    final addToNotifResponse = await supabase.from('notification').insert({
      'appointment_id': widget.appointment['appointment_id'],
      'appointment_notif_type': status, // Or any type based on your logic
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    print('add to notif response: $addToNotifResponse');

    if (response != null) {
      print('Error updating appointment status: ${response.message}');
    } else {
      widget.updateStatus(status);
    }
  }

  // Show confirmation dialog before changing status
  Future<void> showConfirmationDialog(String newStatus) async {
    final confirm = await ConfirmationDialog.show(
      context,
      title: 'Confirm Status',
      content: 'Are you sure you want to change the status to $newStatus?',
    );

    // If the user confirms, update the status
    if (confirm == true) {
      setState(() {
        dropdownValue = newStatus;
      });
      await updateAppointmentStatus(newStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.appointment['services'] as List<dynamic>;
    final packages = widget.appointment['packages'] as List<dynamic>;
    print("Appointment details: ${widget.appointment}");
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
            const Text(
              'Status: ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(160, 62, 6, 1),
              ),
            ),
            const SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Display "Upcoming", "Done", or "Cancelled" as text
                if (dropdownValue == 'Pending') ...[
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await showConfirmationDialog('Upcoming');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[100],
                          foregroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ] else if (dropdownValue == 'Upcoming') ...[
                  const Text(
                    'Upcoming',
                    style: TextStyle(fontSize: 16),
                  ),
                ] else if (dropdownValue == 'Done') ...[
                  const Text(
                    'Done',
                    style: TextStyle(fontSize: 16),
                  ),
                ] else if (dropdownValue == 'Cancelled') ...[
                  const Text(
                    'Cancelled',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ],
            ),

// Buttons below the status text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dropdownValue == 'Upcoming') ...[
                  ElevatedButton(
                    onPressed: dropdownValue == 'Done'
                        ? null
                        : () async {
                            await showConfirmationDialog('Done');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 166, 239, 141),
                      foregroundColor: Color.fromARGB(255, 68, 103, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: dropdownValue == 'Cancelled'
                        ? null
                        : () async {
                            await showConfirmationDialog('Cancelled');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100]!,
                      foregroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
                // No buttons for "Done" or "Cancelled"
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
              child: Text(
                '${widget.appointment['appointment_id'] ?? ''}',
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
            Row(
              children: [
                const Text(
                  "Contact Number:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(), // Add spacing between text and the contact number
                GestureDetector(
                  onTap: () async {
                    final phoneNumber =
                        widget.appointment['pet_owner_phone_number'] ?? '';
                    if (phoneNumber.isNotEmpty) {
                      final uri = Uri.parse('tel:$phoneNumber');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw 'Could not launch $phoneNumber';
                      }
                    }
                  },
                  child: Text(
                    widget.appointment['pet_owner_phone_number'] ?? '',
                    style: const TextStyle(
                      color: Colors.blue, // Makes it look clickable
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Pet Details:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildDetailSection(
                'Pet Name:', '${widget.appointment['pet_name'] ?? ''}'),
            buildDetailSection(
                'Pet Sex:', '${widget.appointment['pet_sex'] ?? ''}'),
            buildDetailSection(
                'Pet Type:', '${widget.appointment['pet_type'] ?? ''}'),
            buildDetailSection(
                'Pet Breed:', '${widget.appointment['pet_breed'] ?? ''}'),
            buildDetailSection('Pet Age:',
                calculateAge(widget.appointment['pet_date_of_birth'])),
            buildDetailSection(
                'Pet Weight:', '${widget.appointment['pet_weight'] ?? ''}'),
            buildDetailSection('Pet Description:',
                '${widget.appointment['pet_description'] ?? ''}'),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Appointment Schedule:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildDetailSection(
              'Date:',
              formatDateToShort(widget.appointment['appointment_date'] ?? ''),
            ),
            buildDetailSection(
              'Time:',
              formatTime(widget.appointment['appointment_time'] ?? ''),
            ),
            const SizedBox(height: 10),
            buildDetailSection('Service Type',
                '${widget.appointment['appointment_type'] ?? ''}'),
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
                  '₱ ${widget.appointment['total_amount'] ?? '0.0'}',
                  style: const TextStyle(
                    fontSize: 18,
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

  // Build detail section method
  Widget buildDetailSection(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
