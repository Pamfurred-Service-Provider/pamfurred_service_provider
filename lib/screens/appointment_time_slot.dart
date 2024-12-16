import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_provider/Widgets/delete_dialog.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase package
import 'package:service_provider/Widgets/error_dialog.dart';
import 'package:service_provider/Widgets/confirmation_dialog.dart';

class AppointmentTimeSlotScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String spId; // Service Provider ID to identify the user in Supabase
  final onFullyBookedChanged;

  const AppointmentTimeSlotScreen({
    super.key,
    required this.selectedDate,
    required this.spId,
    required this.onFullyBookedChanged,
  });
  @override
  State<AppointmentTimeSlotScreen> createState() =>
      AppointmentTimeSlotScreenState();
}

class AppointmentTimeSlotScreenState extends State<AppointmentTimeSlotScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<String> timeSlots = [];
  bool isLoading = false;
  bool isFullyBooked = false;

  final DateFormat dateFormat = DateFormat('MMMM d, y');
  String? userTimeOpen; // User's opening time
  String? userTimeClose; // User's closing time
  @override
  void initState() {
    super.initState();
    fetchUserOpeningAndClosingTime();
    _loadTimeSlots();
  }

  Future<void> fetchUserOpeningAndClosingTime() async {
    final response = await supabase
        .from('service_provider')
        .select('time_open, time_close')
        .eq('sp_id', widget.spId)
        .maybeSingle();

    if (response != null) {
      setState(() {
        userTimeOpen = _formatTime(response['time_open']); // Format time
        userTimeClose = _formatTime(response['time_close']); // Format time
      });
    }
  }

  String _formatTime(String? time) {
    if (time == null) return '';
    final parsedTime = DateFormat("HH:mm:ss").parse(time);
    return DateFormat("HH:mm").format(parsedTime);
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
          .select('timeslots, is_fully_booked')
          .eq('sp_id', widget.spId)
          .eq('availability_date', selectedDateString)
          .maybeSingle();

      if (response != null) {
        setState(() {
          final fetchedSlots = List<String>.from(response['timeslots']);
          isFullyBooked = response['is_fully_booked'];
          timeSlots = fetchedSlots;
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

  Future<void> _toggleFullyBooked() async {
    setState(() {
      isLoading = true;
    });
    // Ensure at least one time slot is added before marking as fully booked
    if (timeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You must add at least one time slot before marking as fully booked.')),
      );
      return;
    }

    // Ensure that the availability record exists before updating 'is_fully_booked'
    final selectedDateString =
        DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    // Attempt to fetch the existing availability record
    final availabilityResponse = await supabase
        .from('service_provider_availability')
        .select('availability_id, is_fully_booked')
        .eq('sp_id', widget.spId)
        .eq('availability_date', selectedDateString)
        .maybeSingle();

    if (availabilityResponse == null) {
      setState(() {
        isFullyBooked = true;
      });
      // No availability exists for this date, so create a new record
      await supabase.from('service_provider_availability').insert({
        'sp_id': widget.spId,
        'availability_date': selectedDateString,
        'timeslots': timeSlots,
        'is_fully_booked': false, // Set initial as not fully booked
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Marked as fully booked! Please click save.')),
      );
    }

    // Update the 'is_fully_booked' status after ensuring the record exists
    final newFullyBookedStatus = !isFullyBooked;
    final response = await supabase
        .from('service_provider_availability')
        .update({'is_fully_booked': newFullyBookedStatus})
        .eq('sp_id', widget.spId)
        .eq('availability_date', selectedDateString)
        .execute();
  }

  void _removeTimeSlot(int index) {
    setState(() {
      timeSlots.removeAt(index);
    });
  }

  void _showBulkAddDialog() {
    if (userTimeOpen == null || userTimeClose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time preferences not loaded')),
      );
      return;
    }
    final List<String> timeOptions = List.generate(
      24,
      (index) => "${index.toString().padLeft(2, '0')}:00",
    );

    final List<int> intervalOptions = [15, 30, 45, 60, 75, 90];

    String? selectedStartTime = userTimeOpen;
    String? selectedEndTime = userTimeClose;
    int? selectedInterval = intervalOptions.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Multiple Time Slots'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: timeOptions.contains(selectedStartTime)
                    ? selectedStartTime
                    : null,
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
                value: timeOptions.contains(selectedEndTime)
                    ? selectedEndTime
                    : null,
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

                  while (currentHour * 60 + currentMinute <=
                      endTime.hour * 60 + endTime.minute) {
                    final slot =
                        "${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}";
                    newSlots.add(slot);

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
                    SnackBar(content: Text('Invalid input')),
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

  Future<void> _saveToSupabase() async {
    if (!isFullyBooked && timeSlots.isEmpty) {
      showErrorDialog(
          context, "You must add at least one(1) time slot before saving.");
      return;
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
      // Check if the record already exists
      final availabilityResponse = await supabase
          .from('service_provider_availability')
          .select('availability_id')
          .eq('sp_id', widget.spId)
          .eq('availability_date', selectedDateString)
          .maybeSingle();

      if (availabilityResponse == null) {
        // Insert new availability record
        await supabase.from('service_provider_availability').insert({
          'sp_id': widget.spId,
          'availability_date': selectedDateString,
          'timeslots': timeSlots,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability saved successfully')),
        );
      } else {
        // If availability exists, update the timeslots
        final availabilityId = availabilityResponse['availability_id'];
        await supabase.from('service_provider_availability').update({
          'timeslots': timeSlots,
        }).eq('availability_id', availabilityId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability updated successfully')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error')),
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
                  style: const TextStyle(fontSize: 18),
                ),
                if (!isFullyBooked)
                  ElevatedButton(
                    onPressed: timeSlots.isEmpty
                        ? null
                        : () async {
                            // Show confirmation dialog
                            bool? confirmed = await ConfirmationDialog.show(
                              context,
                              title: 'Mark as Fully Booked',
                              content:
                                  'Are you sure you want to mark this day as fully booked?',
                            );

                            // If the user confirmed, toggle the fully booked status
                            if (confirmed == true) {
                              await _toggleFullyBooked();
                              widget.onFullyBookedChanged(
                                  true); // Mark as fully booked
                              Navigator.pop(context);
                            }
                          },
                    child: const Text("Mark as Fully Booked"),
                  ),
              ],
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
                        if (!isFullyBooked) ...[
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ShowDeleteDialog(
                                    title: 'Delete Time Slot',
                                    content:
                                        'Are you sure you want to delete this time slot?',
                                    onDelete: () {
                                      _removeTimeSlot(index);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            if (!isFullyBooked) ...[
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomWideButton(
                  text: 'Save',
                  onPressed: _saveToSupabase,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
