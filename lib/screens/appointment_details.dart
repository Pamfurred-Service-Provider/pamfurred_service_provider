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
    // // Check if the current status is 'Done'
    // if (dropdownValue == 'Done') {
    //   // Show an alert that status can't be changed
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Status can't be changed once it's Done")),
    //   );
    //   return;
    // }

    final response = await supabase
        .from('appointment')
        .update({'appointment_status': status}).eq(
            'appointment_id', widget.appointment['appointment_id']);

    if (response != null) {
      print('Error updating appointment status: ${response.message}');
    } else {
      widget.updateStatus(status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.appointment['services'] as List<dynamic>;
    final packages = widget.appointment['packages'] as List<dynamic>;
    // Restrict buttons based on the current status
    final List<String> displayedStatusOptions =
        dropdownValue == 'Done' || dropdownValue == 'Cancelled'
            ? [dropdownValue]
            : statusOptions;

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
              'Status:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(160, 62, 6, 1),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: displayedStatusOptions.map((status) {
                // Define colors and styles based on status
                final isSelected = dropdownValue == status;
                Color backgroundColor;
                Color textColor;

                switch (status) {
                  case 'Done':
                    backgroundColor = isSelected
                        ? Colors.green
                        : Color.fromARGB(255, 166, 239, 141);
                    textColor = isSelected
                        ? Colors.black
                        : Color.fromARGB(255, 68, 103, 56);
                    break;
                  case 'Cancelled':
                    backgroundColor = isSelected
                        ? Color.fromRGBO(164, 36, 36, 1)
                        : Colors.red[100]!;
                    textColor = isSelected ? Colors.white : Colors.red;
                    break;
                  case 'Upcoming':
                    backgroundColor = isSelected
                        ? Color.fromRGBO(251, 188, 4, 1)
                        : Color.fromRGBO(231, 199, 103, 1);
                    textColor = isSelected
                        ? Colors.black
                        : Color.fromRGBO(183, 134, 66, 1);
                    break;
                  default:
                    backgroundColor = Colors.grey[200]!;
                    textColor = Colors.black;
                }

                return ElevatedButton(
                  onPressed: () async {
                    if (!isSelected) {
                      setState(() {
                        dropdownValue = status;
                      });
                      await updateAppointmentStatus(status);
                    } else if (dropdownValue == 'Done' ||
                        dropdownValue == 'Cancelled') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Status can't be changed once it's ${dropdownValue}"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected
                            ? Color.fromARGB(255, 60, 60, 60)
                            : Colors.transparent,
                        width:
                            isSelected ? 2 : 1, // Highlight border for selected
                      ),
                    ),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
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
