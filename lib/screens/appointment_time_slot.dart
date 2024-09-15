import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentTimeSlotScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AppointmentTimeSlotScreen({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  State<AppointmentTimeSlotScreen> createState() =>
      AppointmentTimeSlotScreenState();
}

class AppointmentTimeSlotScreenState extends State<AppointmentTimeSlotScreen> {
  // Predefined time slots
  List<String> availableTimeSlots = [
    "09:00 AM",
    "11:00 AM",
    "01:00 PM",
    "03:00 PM"
  ];

  // Initially selected time slots
  List<String> timeSlots = ["09:00 AM", "11:00 AM", "01:00 PM", "03:00 PM"];

  String dropdownValue = 'Available';
  List<String> availabilityOptions = [
    'Available',
    'Unavailable',
    'Fully Booked'
  ];

  // Method to add a new time slot
  void _addTimeSlot() {
    setState(() {
      // Add the first available time slot as the default when a new slot is added
      timeSlots.add(availableTimeSlots.first);
    });
  }

  // Method to remove a time slot
  void _removeTimeSlot(int index) {
    setState(() {
      timeSlots.removeAt(index);
    });
  }

  final DateFormat dateFormat =
      DateFormat('MMMM d, y'); // Format for month name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeslots"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displaying the selected date (Month, Day, Year)
            Text(
              dateFormat.format(widget.selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dropdown for availability options
            DropdownButtonFormField<String>(
              value: dropdownValue,
              decoration: const InputDecoration(
                labelText: 'Availability',
                border: OutlineInputBorder(),
              ),
              items: availabilityOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Displaying Time Slots with dropdowns and delete buttons
            Expanded(
              child: ListView.builder(
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: timeSlots[index],
                            decoration: InputDecoration(
                              labelText: 'Time Slot',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            items: availableTimeSlots.map((String time) {
                              return DropdownMenuItem<String>(
                                value: time,
                                child: Text(time),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                timeSlots[index] = newValue!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _removeTimeSlot(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // SizedBox to separate the time slots from the buttons
            const SizedBox(height: 20),

            // "Add more" and "Save" buttons
            ElevatedButton.icon(
              onPressed: _addTimeSlot, // Add new time slot
              icon: const Icon(Icons.add),
              label: const Text("Add More"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space between buttons
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 16),
                    SizedBox(width: 15),
                    Text("Save"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
