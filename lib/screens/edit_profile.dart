import 'package:flutter/material.dart';
import 'package:service_provider/screens/appointment_time_slot.dart';
import 'package:service_provider/screens/pin_location.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.profileData});
  final Map<String, dynamic>? profileData;

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

//Static Data
const List<String> number = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
final Map<DateTime, bool> _availability = {
  DateTime.utc(2024, 9, 10): false, // Fully booked
  DateTime.utc(2024, 9, 11): true, // Available
  DateTime.utc(2024, 9, 12): true, // Available
};
List<String> petsList = ['dog'];

class EditProfileScreenState extends State<EditProfileScreen> {
  // Initialize Supabase and user session variables
  final supabase = Supabase.instance.client;
  late final String userId;
  String dropdownValue = number.first; //dropdown for # of pets catered per day

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
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();

  bool _isDayAvailable(DateTime day) {
    return _availability[DateTime.utc(day.year, day.month, day.day)] ?? true;
  }

  @override
  void initState() {
    super.initState();

    // Retrieve the user ID from the Supabase session
    final serviceSession = supabase.auth.currentSession;
    userId = serviceSession?.user?.id ?? '';
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

      if (serviceProviderResponse.error == null &&
          serviceProviderResponse.data != null) {
        setState(() {
          // Prefill the service provider data
          establishmentNameController.text =
              serviceProviderResponse.data['name'] ?? '';
          timeOpenController.text =
              serviceProviderResponse.data['time_open'] ?? '';
          timeCloseController.text =
              serviceProviderResponse.data['time_close'] ?? '';
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
              '${addressData['city'] ?? "Not Available"}, '
              '${addressData['barangay'] ?? "Not Available"}, '
              '${addressData['street'] ?? "Not Available"}, '
              '${addressData['latitude'] ?? "Not Available"}, '
              '${addressData['longitude'] ?? "Not Available"}';
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
        cityController.text = selectedLocation['city'] ?? 'N/A';
        barangayController.text = selectedLocation['province'] ?? 'N/A';
        streetController.text = selectedLocation['streetAddress'] ?? 'N/A';
        exactAddressController.text =
            'City: ${selectedLocation['city'] ?? "Not Available"}, '
            'Province: ${selectedLocation['province'] ?? "Not Available"}, '
            'Street: ${selectedLocation['streetAddress'] ?? "Not Available"}, '
            'Latitude: ${selectedLocation['latitude']}, '
            'Longitude: ${selectedLocation['longitude']}'; // Set location text
      });
    }
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
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2030, 1, 1),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              selectedDayPredicate: (day) {
                return false; // No pre-selection logic, so this can be kept as is
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
                  bool isAvailable = _isDayAvailable(day);
                  bool isPast =
                      day.isBefore(DateTime.now().subtract(Duration(days: 1)));

                  return Container(
                    decoration: BoxDecoration(
                      color: isPast
                          ? Colors.grey // Gray color for past days
                          : (isAvailable ? Colors.green : Colors.red),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    margin: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isPast
                              ? Colors.black
                              : Colors.white, // Black text for past days
                        ),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  bool isAvailable = _isDayAvailable(day);
                  bool isPast =
                      day.isBefore(DateTime.now().subtract(Duration(days: 1)));

                  return Container(
                    decoration: BoxDecoration(
                      color: isPast
                          ? Colors.grey // Gray color for past days
                          : (isAvailable ? Colors.green : Colors.red),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    margin: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isPast
                              ? Colors.black
                              : Colors.white, // Black text for past days
                        ),
                      ),
                    ),
                  );
                },
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
                        Icons.location_on,
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
                  controller: cityController,
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
