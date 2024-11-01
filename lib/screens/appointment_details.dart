import 'package:flutter/material.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final Function(String) updateStatus;

  const AppointmentDetailScreen(
      {super.key, required this.appointment, required this.updateStatus});

  @override
  AppointmentDetailScreenState createState() => AppointmentDetailScreenState();
}

class AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late String dropdownValue;
  final List<String> statusOptions = ['Done', 'Cancelled', 'Upcoming'];

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.appointment['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                "Appointment ID: ${widget.appointment['id']}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: dropdownValue,
                  items: statusOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null && newValue != dropdownValue) {
                      setState(() {
                        dropdownValue = newValue;
                      });
                      widget.updateStatus(newValue);
                    }
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  'Date:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.appointment['date']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Time:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.appointment['time']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Name:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.appointment['name']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Phone Number:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.appointment['phone']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pet Category:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.appointment['category']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Service Type:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.appointment['type']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Service Availed:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                if (widget.appointment['services'] != null &&
                    widget.appointment['services'] is List)
                  ...List<Widget>.generate(
                      widget.appointment['services'].length, (index) {
                    var service = widget.appointment['services'][index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${service['service']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '₱ ${service['price']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 10),
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
                      '₱ ${widget.appointment['total']}',
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
          ],
        ),
      ),
    );
  }
}
