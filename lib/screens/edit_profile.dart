import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_provider/components/width_expanded_button.dart';
import 'package:service_provider/screens/appointment_time_slot.dart';
import 'package:service_provider/screens/pin_location.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/components/date_and_time_formatter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.profileData});
  final Map<String, dynamic>? profileData;

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

//Static Data
Map<DateTime, bool> _availability =
    {}; // Track availability (fully booked or not)
List<String> petsList = ['dog'];
final List<int> intervalOptions = [
  15,
  30,
  45,
  60,
  75,
  90
]; // Available intervals
int selectedInterval = 30;
// Days of the week availability
Map<String, bool> availability = {
  'Monday': false,
  'Tuesday': false,
  'Wednesday': false,
  'Thursday': false,
  'Friday': false,
  'Saturday': false,
  'Sunday': false,
};

class EditProfileScreenState extends State<EditProfileScreen> {
  // Initialize Supabase and user session variables
  final supabase = Supabase.instance.client;
  late final String userId;

  // Controllers
  final TextEditingController establishmentNameController =
      TextEditingController();
  final TextEditingController timeOpenController = TextEditingController();
  final TextEditingController timeCloseController = TextEditingController();
  final TextEditingController intervalController = TextEditingController();
  final TextEditingController petsToCaterController = TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  final TextEditingController exactAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController floorNoController = TextEditingController();

// Variables for selected location
  double? pinnedLatitude;
  double? pinnedLongitude;
  String? pinnedAddress;

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final time24Hour =
          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      controller.text = time24Hour; // Store in 24-hour format
    }
  }

  List<String> generateTimeSlots(
      String timeOpen, String timeClose, int intervalMinutes, DateTime date) {
    final List<String> timeSlots = [];
    final DateFormat inputFormat = DateFormat('hh:mm a'); // Input format
    final DateFormat outputFormat = DateFormat('HH:mm'); // Output format

    final DateTime timeOpenDateTime = inputFormat.parse(timeOpen);
    final DateTime timeCloseDateTime = inputFormat.parse(timeClose);

    final int openHour = timeOpenDateTime.hour;
    final int openMinute = timeOpenDateTime.minute;
    final int closeHour = timeCloseDateTime.hour;
    final int closeMinute = timeCloseDateTime.minute;

    DateTime startTime =
        DateTime(date.year, date.month, date.day, openHour, openMinute);
    DateTime endTime =
        DateTime(date.year, date.month, date.day, closeHour, closeMinute);

    while (startTime.isBefore(endTime)) {
      timeSlots.add(
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}");
      startTime = startTime.add(Duration(minutes: intervalMinutes));
    }

    return timeSlots;
  }

  Future<void> saveTimeSlotsForDateRange(String timeOpen, String timeClose,
      int intervalMinutes, DateTime startDate, DateTime endDate) async {
    List<Map<String, dynamic>> records = [];

    for (DateTime currentDate = startDate;
        currentDate.isBefore(endDate);
        currentDate = currentDate.add(Duration(days: 1))) {
      final timeSlots =
          generateTimeSlots(timeOpen, timeClose, intervalMinutes, currentDate);

      records.add({
        'availability_date': DateFormat('yyyy-MM-dd').format(currentDate),
        'sp_id': userId,
        'timeslots': timeSlots, // Store as JSON array
        'is_fully_booked': false,
      });
    }

    try {
      if (records.isNotEmpty) {
        // Batch insert records
        await supabase.from('service_provider_availability').insert(records);
        print("Time slots saved successfully.");
      } else {
        print("No time slots to save.");
      }
    } catch (e) {
      print("Error saving time slots: $e");
    }
  }

  final CalendarFormat _calendarFormat = CalendarFormat.month;

  Future<bool> _isDayAvailable(DateTime day) async {
    // Format the selected day into the 'yyyy-MM-dd' format to match the `availability_date` format in your table
    String formattedDate =
        "${day.toLocal().year.toString().padLeft(4, '0')}-${day.toLocal().month.toString().padLeft(2, '0')}-${day.toLocal().day.toString().padLeft(2, '0')}";

    try {
      // Query the Supabase table to check availability for the given day
      final response = await Supabase.instance.client
          .from('service_provider_availability') // Your table name
          .select('is_fully_booked') // Select the availability status
          .eq('availability_date', formattedDate) // Match the date
          .eq('sp_id',
              userId) // Ensure you're checking for the current service provider's availability
          .maybeSingle(); // Use maybeSingle to handle null if no match is found

      if (response == null) {
        // If no record is found, assume the day is available
        return true;
      }

      // Return true if not fully booked, false otherwise
      return response['is_fully_booked'] == false;
    } catch (error) {
      // Log error for debugging
      print('Error fetching day availability: $error');
      // Handle errors gracefully (optional: mark as available by default)
      return true;
    }
  }

// Function to update the availability of a specific date
  void updateAvailability(DateTime date, bool isFullyBooked) {
    setState(() {
      _availability[date] = isFullyBooked;
    });
  }

  @override
  void initState() {
    super.initState();

    // Retrieve the user ID from the Supabase session
    final serviceSession = supabase.auth.currentSession;
    userId = serviceSession?.user.id ?? '';
    print('User ID: $userId');

    // Fetch the user's service provider data from Supabase
    _fetchServiceProviderData();
  }

  Future<void> _fetchServiceProviderData() async {
    try {
      // Fetch the service provider data based on the logged-in user's ID
      final serviceProviderResponse = await supabase
          .from('service_provider')
          .select('name, time_open, time_close')
          .eq('sp_id',
              userId) // Assuming 'sp_id' is the field that corresponds to the user ID
          .single();
      print('Service Provider Raw Response: $serviceProviderResponse');

      // Fetch the address data based on the logged-in user's ID
      final addressResponse = await supabase
          .from('user')
          .select(
              'address:address_id(floor_unit_room, street, city, barangay, latitude, longitude)') // Using relation with foreign key
          .eq('user_id', userId) // Fetch the data  for the logged-in user
          .single();
// Helper method to convert time to 24-hour format

      if (serviceProviderResponse != null) {
        print(
            'Service Provider Data: ${serviceProviderResponse}'); // Print the actual data

        setState(() {
          // Prefill the service provider data
          establishmentNameController.text =
              serviceProviderResponse['name'] ?? '';
          // Convert time_open to 12-hour format (HH:mm) AM/PM
          timeOpenController.text =
              convertTo12HourFormat(serviceProviderResponse['time_open'] ?? '');
          timeCloseController.text = convertTo12HourFormat(
              serviceProviderResponse['time_close'] ?? '');
        });
      } else {
        print(
            'Error fetching service provider data: ${serviceProviderResponse}');
      }

      if (addressResponse != null) {
        setState(() {
          var addressData =
              addressResponse['address']; // Address data from the response
          pinnedLatitude = addressData['latitude'];
          pinnedLongitude = addressData['longitude'];
          pinnedAddress =
              '${addressData['street']}, ${addressData['barangay']}, ${addressData['city']}';

          // Prefill the address data
          floorNoController.text = addressData['floor_unit_room'] ?? '';
          streetController.text = addressData['street'] ?? '';
          barangayController.text = addressData['barangay'] ?? '';
          cityController.text = addressData['city'] ?? '';
          exactAddressController.text = pinnedAddress!;
        });
      } else {
        print('Error fetching address data: ${addressResponse}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> saveProfile() async {
    String timeOpen = timeOpenController.text;
    String timeClose = timeCloseController.text;
    int intervalMinutes = selectedInterval;
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(Duration(days: 5));

    print(
        "Generated time slots for the next 30 days: ${generateTimeSlots(timeOpen, timeClose, intervalMinutes, startDate).length}");
    print("Establishment Name: ${establishmentNameController.text}");
    print("Time Open: ${timeOpenController.text}");
    print("Time Close: ${timeCloseController.text}");
    print("Interval: $selectedInterval minutes");
    print("Selected Days for Availability: $availability");
    // Save all time slots to the database in a single batch
    await saveTimeSlotsForDateRange(
        timeOpen, timeClose, intervalMinutes, startDate, endDate);

    // 1. Fetch the address_id of the user
    final userResponse = await supabase
        .from('user')
        .select('address_id')
        .eq('user_id', userId)
        .single();

    if (userResponse == null || userResponse['address_id'] == null) {
      print('No address ID found for the user');
      return;
    }
    final addressId = userResponse['address_id'];
    print('Fetched Address ID: $addressId');

    // 2. Prepare the updated profile data (service provider)
    final updatedProfile = {
      'name': establishmentNameController.text,
      'time_open': timeOpenController.text,
      'time_close': timeCloseController.text,
    };

    try {
      // 3. Update service provider information
      final response = await supabase
          .from('service_provider')
          .update(updatedProfile)
          .eq('sp_id', userId); // Match the sp_id with userId
    } catch (e) {
      print('Error updating service provider profile:${e.toString()}');

      // 4. Update the address table with the new address details
      final updatedAddress = {
        'city': cityController.text,
        'barangay': barangayController.text,
        'street': streetController.text,
        'floor_unit_room':
            floorNoController.text, // Assuming this is where floor_no is stored
      };

      final addressResponse = await supabase
          .from('address')
          .update(updatedAddress)
          .eq('address_id', addressId);

      print('Error updating address: ${addressResponse}');
    }
  }

  Future<void> navigateToPinLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PinLocationNew()),
    );

    if (result != null) {
      setState(() {
        pinnedLatitude = result['latitude'];
        pinnedLongitude = result['longitude'];
        pinnedAddress = result['address'];

        List<String> addressParts = pinnedAddress!.split(', ');

        // Populate form fields with address components
        streetController.text = addressParts.isNotEmpty ? addressParts[0] : '';
        barangayController.text =
            addressParts.length > 1 ? addressParts[1] : '';
        cityController.text = addressParts.length > 2 ? addressParts[2] : '';
        exactAddressController.text = pinnedAddress!;
      });
    } else {
      // Handle the case when no location is selected
      print('No location selected');
    }
  }

  // Validate the form fields and location data
  bool validateFields() {
    final street = streetController.text.trim();
    final barangay = barangayController.text.trim();

    return pinnedLatitude != null &&
        pinnedLongitude != null &&
        pinnedAddress != null &&
        street.isNotEmpty &&
        barangay.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Establishment name",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: establishmentNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Time Open",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: timeOpenController,
                        readOnly: true, // Makes the text field read-only
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                        onTap: () => _selectTime(context,
                            timeOpenController), // Show time picker when tapped
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Time Close",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: timeCloseController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                        ),
                        onTap: () => _selectTime(context,
                            timeCloseController), // Show time picker when tapped
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Service Time Interval",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: selectedInterval,
                  items: intervalOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value minutes'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedInterval = newValue;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Select interval',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Days for Availability",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...availability.keys.map((day) {
            return CheckboxListTile(
              title: Text(day),
              value: availability[day],
              onChanged: (bool? value) {
                setState(() {
                  availability[day] = value ?? false;
                });
              },
            );
          }).toList(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 1, 1),
              focusedDay:
                  DateTime.now(), // Set this to today's date for initialization
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              selectedDayPredicate: (day) {
                // No pre-selection logic, keep it disabled
                return false;
              },
              onDaySelected: (selectedDay, focusedDay) {
                // Allow selection only for today or future dates
                if (!selectedDay.isBefore(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ))) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentTimeSlotScreen(
                          selectedDate: selectedDay,
                          spId: userId,
                          onFullyBookedChanged: (isFullyBooked) {
                            setState(() {
                              _availability[selectedDay] = isFullyBooked;
                            });
                          }),
                    ),
                  );
                }
              },

              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  // Strip time component for proper day comparison
                  bool isPast = day.isBefore(DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  ));

                  // Handle past days
                  if (isPast) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey, // Always gray for past days
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: Colors.black, // Black text for past days
                          ),
                        ),
                      ),
                    );
                  }

                  // FutureBuilder for non-past days
                  return FutureBuilder<bool>(
                    future: _isDayAvailable(
                        day), // Fetch the availability asynchronously
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.green, // Assume available (green)
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        print('Error fetching data: ${snapshot.error}');
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.red, // Show error color
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                        );
                      } else {
                        bool isAvailable =
                            snapshot.data ?? true; // Default to true if no data

                        return Container(
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green
                                : Colors.red, // Green if available, red if not
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors
                      .transparent, // No special styling for the focused day
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.green, // Green background for today
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Colors.white, // White text for today
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          //Legend Indicator
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(Colors.green, "Available"),
                const SizedBox(width: 15),
                _buildIndicator(Colors.red, "Fully Booked"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Business Establishment Address",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                const Text("Pin Address"),
                const SizedBox(height: 20),
                TextField(
                  controller: exactAddressController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.location_searching,
                        color: Color(0xFFA03E06),
                      ),
                      onPressed: navigateToPinLocation,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2, // Adjust flex to control the width ratio
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Floor/Unit/Room No.",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: floorNoController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16), // Space between the fields
                    Expanded(
                      flex: 3, // Adjust flex to control the width ratio
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Street",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: streetController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomWideButton(
              text: 'Save',
              onPressed: saveProfile,
              leadingIcon: Icons.check,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Method to build the circle indicators for the legend
  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
