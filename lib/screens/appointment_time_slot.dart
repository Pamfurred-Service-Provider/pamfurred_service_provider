import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase package
import 'package:service_provider/Widgets/error_dialog.dart';

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

  // Initially selected time slots and availability status
  List<String> timeSlots = [];
  bool isLoading = false; // Loading state for save operation
  bool isFullyBooked = false; // Tracks if the day is fully booked

  final DateFormat dateFormat = DateFormat('MMMM d, y'); // Format for month e

  @override
  void initState() {
    super.initState();
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    setState(() {
      isLoading = true;
    });

    final selectedDateString =
        DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    try {
      final response = await supabase
          .from('service_provider_availability')
          .select('timeslots')
          .eq('sp_id', widget.spId)
          .eq('availability_date', selectedDateString)
          .maybeSingle();

      if (response != null) {
        setState(() {
          final fetchedSlots = List<String>.from(response['timeslots']);
          if (fetchedSlots.contains('FULLY_BOOKED')) {
            isFullyBooked = true;
            timeSlots = []; // No specific slots if fully booked
          } else {
            isFullyBooked = false;
            timeSlots = fetchedSlots;
          }
        });
      } else {
        setState(() {
          isFullyBooked = false;
          timeSlots = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading time slots')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleFullyBooked() async {
    // Toggle the "Fully Booked" state in the UI
    setState(() {
      isFullyBooked = !isFullyBooked;
    });

    // Format the selected date to 'yyyy-MM-dd' format
    String selectedDateString =
        DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    try {
      // Update the `is_fully_booked` column in Supabase
      final response = await supabase
          .from('service_provider_availability')
          .update({'is_fully_booked': isFullyBooked}) // Update the field
          .eq('sp_id', widget.spId) // Filter by service provider ID
          .eq('availability_date',
              selectedDateString) // Filter by the selected date
          .execute();

      if (response != null) {
        // Show an error if the update fails
      } else {
        // Optionally, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isFullyBooked
                  ? 'Marked as fully booked'
                  : 'Unmarked as fully booked')),
        );

        // Reload the time slots from the database to reflect the change
        _loadTimeSlots(); // Re-fetch the availability from Supabase
      }
    } catch (e) {
      // Handle any errors that might occur during the update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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

    final List<int> intervalOptions = [
      15,
      30,
      45,
      60,
      75,
      90
    ]; // Intervals in minutes

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
    if (!isFullyBooked && timeSlots.isEmpty) {
      // Use the provided showErrorDialog function
      showErrorDialog(
          context, "You must add at least one time slot before saving.");
      return; // Exit the method early
    }
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

      if (availabilityResponse == null) {
        await supabase.from('service_provider_availability').insert({
          'sp_id': widget.spId,
          'availability_date': selectedDateString,
          'timeslots': timeSlots,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability saved successfully')),
        );
        Navigator.pop(context);
      } else {
        final availabilityId = availabilityResponse['availability_id'];
        await supabase.from('service_provider_availability').update({
          'timeslots': timeSlots,
        }).eq('availability_id', availabilityId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability updated successfully')),
        );
        Navigator.pop(context);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(widget.selectedDate),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _toggleFullyBooked,
                  child: Text(isFullyBooked
                      ? "Unmark Fully Booked"
                      : "Mark as Fully Booked"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isFullyBooked)
              const Text(
                "This day is fully booked.",
                style: TextStyle(fontSize: 16, color: Colors.red),
              )
            else
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
                                    timeSlots[index] =
                                        pickedTime.format(context);
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
