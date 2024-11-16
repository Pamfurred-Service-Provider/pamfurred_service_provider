import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase package

class AppointmentTimeSlotScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String spId; // Service Provider ID to identify the user in Supabase

  const AppointmentTimeSlotScreen({super.key, required this.selectedDate, required this.spId});

  @override
  State<AppointmentTimeSlotScreen> createState() => AppointmentTimeSlotScreenState();
}

class AppointmentTimeSlotScreenState extends State<AppointmentTimeSlotScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Predefined time slots
  List<String> availableTimeSlots = ["09:00 AM", "11:00 AM", "01:00 PM", "03:00 PM"];
  
  // Initially selected time slots and availability status
  List<String> timeSlots = ["09:00 AM", "11:00 AM", "01:00 PM", "03:00 PM"];
  String dropdownValue = 'Available';

  List<String> availabilityOptions = ['Available', 'Unavailable', 'Fully Booked'];

  final DateFormat dateFormat = DateFormat('MMMM d, y'); // Format for month name

  // Method to add a new time slot
  void _addTimeSlot() {
    setState(() {
      timeSlots.add(availableTimeSlots.first);
    });
  }

  // Method to remove a time slot
  void _removeTimeSlot(int index) {
    setState(() {
      timeSlots.removeAt(index);
    });
  }

  // Method to save data to Supabase
  Future<void> _saveToSupabase() async {
    final selectedDateString = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    try {
      // Check if there's an existing availability record for this sp_id and availability_date
      final availabilityResponse = await supabase
          .from('service_provider_availability')
          .select('availability_id')
          .eq('sp_id', widget.spId)
          .eq('availability_date', selectedDateString)
          .maybeSingle() // Use maybeSingle() to avoid error when no rows are found
          .execute();

      if (availabilityResponse.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking availability: ${availabilityResponse.error!.message}')),
        );
        return;
      }

      if (availabilityResponse.data == null) {
        // If no matching record found, insert new data
        final insertResponse = await supabase.from('service_provider_availability').insert({
          'sp_id': widget.spId,
          'availability_date': selectedDateString, // Ensure it's only the date, no timestamp
          'timeslots': timeSlots,
          'status': dropdownValue,
        }).execute();

        if (insertResponse.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error inserting data: ${insertResponse.error!.message}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Availability saved successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        // If matching record found, update the existing row with the new time slots
        final availabilityId = availabilityResponse.data['availability_id'];

        final updateResponse = await supabase
            .from('service_provider_availability')
            .update({
              'timeslots': timeSlots, // Update timeslots with new ones
              'status': dropdownValue, // Update availability status
            })
            .eq('availability_id', availabilityId) // Use the availability_id for the update
            .eq('sp_id', widget.spId) // Ensure sp_id matches as well
            .eq('availability_date', selectedDateString) // Ensure the date matches as well
            .execute();

        if (updateResponse.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating data: ${updateResponse.error!.message}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Availability updated successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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
                return DropdownMenuItem<String>(value: option, child: Text(option));
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
                              return DropdownMenuItem<String>(value: time, child: Text(time));
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

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _addTimeSlot,
              icon: const Icon(Icons.add),
              label: const Text("Add More"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _saveToSupabase, // Save button calls save method
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

extension on PostgrestResponse {
  get error => null;
}
