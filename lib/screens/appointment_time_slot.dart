import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase package

class AppointmentTimeSlotScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String spId; // Service Provider ID to identify the user in Supabase

  const AppointmentTimeSlotScreen(
      {super.key, required this.selectedDate, required this.spId});

  @override
  State<AppointmentTimeSlotScreen> createState() =>
      AppointmentTimeSlotScreenState();
}

class AppointmentTimeSlotScreenState extends State<AppointmentTimeSlotScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Predefined time slots
  List<String> availableTimeSlots = ["08:30", "11:00", "01:00", "03:00"];

  // Initially selected time slots and availability status
  List<String> timeSlots = ["09:00", "11:00", "01:00", "03:00"];
  String dropdownValue = 'Available';
  List<String> availabilityOptions = [
    'Available',
    'Unavailable',
    'Fully Booked'
  ];

  bool isLoading = false; // Loading state for save operation

  final DateFormat dateFormat = DateFormat('MMMM d, y'); // Format for month e

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

  // Method to show bulk add dialog
  void _showBulkAddDialog() {
    // Time options in 24-hour format (HH:mm)
    final List<String> timeOptions = List.generate(
      24,
      (index) => "${index.toString().padLeft(2, '0')}:00",
    );

    final List<int> intervalOptions = [15, 30, 45, 60]; // Intervals in minutes

    String? selectedStartTime = timeOptions.first; // Default to "00:00"
    String? selectedEndTime = timeOptions.last; // Default to "23:00"
    int? selectedInterval = intervalOptions.first; // Default to 15 minutes

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Multiple Time Slots'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedStartTime,
                items: timeOptions
                    .map((time) =>
                        DropdownMenuItem(value: time, child: Text(time)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStartTime = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Start Time'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedEndTime,
                items: timeOptions
                    .map((time) =>
                        DropdownMenuItem(value: time, child: Text(time)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEndTime = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'End Time'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedInterval,
                items: intervalOptions
                    .map((interval) => DropdownMenuItem(
                        value: interval, child: Text('$interval minutes')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedInterval = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Interval'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  final startTime = TimeOfDay(
                    hour: int.parse(selectedStartTime!.split(":")[0]),
                    minute: int.parse(selectedStartTime!.split(":")[1]),
                  );
                  final endTime = TimeOfDay(
                    hour: int.parse(selectedEndTime!.split(":")[0]),
                    minute: int.parse(selectedEndTime!.split(":")[1]),
                  );

                  if (startTime.hour * 60 + startTime.minute >=
                      endTime.hour * 60 + endTime.minute) {
                    throw Exception('Start time must be before end time.');
                  }

                  final newSlots = <String>[];
                  var currentHour = startTime.hour;
                  var currentMinute = startTime.minute;

                  // Generate time slots in 24-hour format
                  while (currentHour * 60 + currentMinute <=
                      endTime.hour * 60 + endTime.minute) {
                    final slot =
                        "${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}";
                    newSlots.add(slot);

                    // Increment by interval
                    currentMinute += selectedInterval!;
                    if (currentMinute >= 60) {
                      currentMinute -= 60;
                      currentHour += 1;
                    }
                  }

                  setState(() {
                    timeSlots.addAll(
                        newSlots.where((slot) => !timeSlots.contains(slot)));
                  });

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid input: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Method to save data to Supabase
  Future<void> _saveToSupabase() async {
    final selectedDateString =
        DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    if (timeSlots.toSet().length != timeSlots.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duplicate time slots are not allowed')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final availabilityResponse = await supabase
          .from('service_provider_availability')
          .select('availability_id')
          .eq('sp_id', widget.spId)
          .eq('availability_date', selectedDateString)
          .maybeSingle();

      if (availabilityResponse != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error checking availability: ${availabilityResponse!.message}')),
        );
        return;
      }

      if (availabilityResponse == null) {
        final insertResponse =
            await supabase.from('service_provider_availability').insert({
          'sp_id': widget.spId,
          'availability_date': selectedDateString,
          'timeslots': timeSlots,
          'status': dropdownValue,
        });

        if (insertResponse != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error inserting data: ${insertResponse!.message}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Availability saved successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        final availabilityId = availabilityResponse['availability_id'];
        final updateResponse = await supabase
            .from('service_provider_availability')
            .update({
              'timeslots': timeSlots,
              'status': dropdownValue,
            })
            .eq('availability_id', availabilityId)
            .eq('sp_id', widget.spId)
            .eq('availability_date', selectedDateString);

        if (updateResponse != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error updating data: ${updateResponse!.message}')),
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
    } finally {
      setState(() {
        isLoading = false;
      });
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
            Text(
              dateFormat.format(widget.selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              isSelected: availabilityOptions
                  .map((option) => option == dropdownValue)
                  .toList(),
              children: availabilityOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(option),
                );
              }).toList(),
              onPressed: (index) {
                setState(() {
                  dropdownValue = availabilityOptions[index];
                });
              },
            ),
            const SizedBox(height: 20),
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
                          child: InkWell(
                            onTap: () async {
                              final pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  DateFormat.jm().parse(timeSlots[index]),
                                ),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  timeSlots[index] = pickedTime.format(context);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(timeSlots[index]),
                            ),
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
            ElevatedButton.icon(
              onPressed: _showBulkAddDialog,
              icon: const Icon(Icons.schedule),
              label: const Text("Add Multiple Slots"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveToSupabase,
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
