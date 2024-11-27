import 'package:flutter/material.dart';
import 'package:service_provider/screens/appointment_time_slot.dart';
import 'package:service_provider/screens/pin_location.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service_provider/components/date_and_time_formatter.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.profileData});
  final Map<String, dynamic>? profileData;

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

//Static Data
const List<String> number = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
Map<DateTime, bool> _availability =
    {}; // Track availability (fully booked or not)
List<String> petsList = ['dog'];

class EditProfileScreenState extends State<EditProfileScreen> {
  // Initialize Supabase and user session variables
  final supabase = Supabase.instance.client;
  late final String userId;
  String dropdownValue = number.first; //dropdown for # of pets catered per day
  final Region predefinedRegion = philippineRegions.firstWhere(
    (region) => region.regionName == 'REGION X',
  );
  final Province predefinedProvince = philippineRegions
      .firstWhere((region) => region.regionName == 'REGION X')
      .provinces
      .firstWhere((province) => province.name == 'MISAMIS ORIENTAL');

  Municipality? municipality;
  String? barangay;

  // Controllers
  final TextEditingController establishmentNameController =
      TextEditingController();
  final TextEditingController timeOpenController = TextEditingController();
  final TextEditingController timeCloseController = TextEditingController();
  final TextEditingController petsToCaterController = TextEditingController();
  final TextEditingController numberOfPetsCaterController =
      TextEditingController();
  final TextEditingController datePickerController = TextEditingController();
  final TextEditingController exactAddressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController barangayController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController floorNoController = TextEditingController();

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

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();

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
  void _updateAvailability(DateTime date, bool isFullyBooked) {
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
          .select('name, time_open, time_close, number_of_pets')
          .eq('sp_id',
              userId) // Assuming 'sp_id' is the field that corresponds to the user ID
          .single()
          .execute();

      // Fetch the address data based on the logged-in user's ID
      final addressResponse = await supabase
          .from('user')
          .select(
              'address:address_id(floor_unit_room, street, city, barangay, latitude, longitude)') // Using relation with foreign key
          .eq('user_id', userId) // Fetch the data for the logged-in user
          .single()
          .execute();
// Helper method to convert time to 24-hour format

      if (serviceProviderResponse.error == null &&
          serviceProviderResponse.data != null) {
        setState(() {
          // Prefill the service provider data
          establishmentNameController.text =
              serviceProviderResponse.data['name'] ?? '';
          // Convert time_open to 12-hour format (HH:mm) AM/PM
          timeOpenController.text = convertTo12HourFormat(
              serviceProviderResponse.data['time_open'] ?? '');
          timeCloseController.text = convertTo12HourFormat(
              serviceProviderResponse.data['time_close'] ?? '');

          dropdownValue =
              serviceProviderResponse.data['number_of_pets'].toString();
        });
      } else {
        print(
            'Error fetching service provider data: ${serviceProviderResponse.error?.message}');
      }

      if (addressResponse.error == null && addressResponse.data != null) {
        setState(() {
          var addressData =
              addressResponse.data['address']; // Address data from the response

          // Prefill the address data
          floorNoController.text = addressData['floor_unit_room'] ?? '';
          streetController.text = addressData['street'] ?? '';
          cityController.text = addressData['city'] ?? '';
          barangayController.text = addressData['barangay'] ?? '';

          // For exactAddressController, format the address as needed
          exactAddressController.text =
              '${addressData['city'] ?? "Not Found"}, '
              '${addressData['barangay'] ?? "Not Found"}, '
              '${addressData['street'] ?? "Not Found"}, '
              '${addressData['latitude'] ?? "Not Found"}, '
              '${addressData['longitude'] ?? "Not Found"}';
        });
      } else {
        print('Error fetching address data: ${addressResponse.error?.message}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> saveProfile() async {
    // 1. Fetch the address_id of the user
    final userResponse = await supabase
        .from('user')
        .select('address_id')
        .eq('user_id', userId)
        .single()
        .execute();

    if (userResponse.error != null || userResponse.data == null) {
      print('Error fetching user address ID: ${userResponse.error?.message}');
      return;
    }

    final addressId = userResponse.data['address_id'];

    // 2. Prepare the updated profile data (service provider)
    final updatedProfile = {
      'name': establishmentNameController.text,
      'time_open': timeOpenController.text,
      'time_close': timeCloseController.text,
      'number_of_pets': dropdownValue,
    };

    try {
      // 3. Update service provider information
      final response = await supabase
          .from('service_provider')
          .update(updatedProfile)
          .eq('sp_id', userId) // Match the sp_id with userId
          .execute();

      if (response.error == null) {
        print('Service provider profile updated successfully');
      } else {
        print(
            'Error updating service provider profile: ${response.error?.message}');
      }

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
          .eq('address_id', addressId)
          .execute();

      if (addressResponse.error == null) {
        // Address updated successfully
        print('Address updated successfully');
        Navigator.pop(context, updatedProfile); // Return updated profile
      } else {
        print('Error updating address: ${addressResponse.error?.message}');
      }
    } catch (error) {
      print('Error saving profile: $error');
    }
  }

  Future<void> navigateToPinAddress() async {
    // Navigate to PinAddress and wait for the result
    final Map<String, dynamic>? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinAddress(),
      ),
    );

    // If a location is returned, set it in the controller
    if (selectedLocation != null) {
      setState(() {
        cityController.text = selectedLocation['city'] ?? 'Not Found';
        barangayController.text = selectedLocation['barangay'] ?? 'Not Found';
        streetController.text =
            selectedLocation['streetAddress'] ?? 'Not Found';
        exactAddressController.text =
            'Floor: ${selectedLocation['floor_unit_room'] ?? "Not Available"}, '
            'City: ${selectedLocation['city'] ?? "Not Available"}, '
            'Barangay: ${selectedLocation['barangay'] ?? "Not Available"}, '
            'Province: ${selectedLocation['province'] ?? "Not Available"}, '
            'Street: ${selectedLocation['streetAddress'] ?? "Not Available"}, '
            'Latitude: ${selectedLocation['latitude']}, '
            'Longitude: ${selectedLocation['longitude']}'; // Set location text
      });
    }
    print('selectedLocation: $selectedLocation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: ListView(
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Maximum number of pets to cater per days",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: dropdownValue, // Default value
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                  ),
                  items: number.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
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
                // Only navigate if the selected day is not in the past
                if (selectedDay
                    .isAfter(DateTime.now().subtract(Duration(days: 1)))) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentTimeSlotScreen(
                        selectedDate: selectedDay,
                        spId: userId,
                      ),
                    ),
                  );
                }
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  bool isPast =
                      day.isBefore(DateTime.now().subtract(Duration(days: 1)));
                  bool isToday = day.isAtSameMomentAs(DateTime.now());

                  // Handle past days
                  if (isPast) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey, // Gray color for past days
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      margin: const EdgeInsets.all(4.0),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                              color: Colors.black), // Black text for past days
                        ),
                      ),
                    );
                  }

                  // Use FutureBuilder for non-past days, including today
                  return FutureBuilder<bool>(
                    future: _isDayAvailable(
                        day), // Fetch the availability asynchronously
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.green
                                : Colors
                                    .blueGrey, // Green for today during loading
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.all(4.0),
                          child: Center(
                            child:
                                CircularProgressIndicator(), // Show loading indicator
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
                              style: TextStyle(
                                  color: Colors
                                      .white), // White text for non-past days
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
                      onPressed: navigateToPinAddress,
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Barangay",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: barangayController,
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "City",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: cityController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveProfile,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 16),
                SizedBox(width: 15),
                Text("Save"),
              ],
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

extension on PostgrestResponse {
  get error => null;
}
