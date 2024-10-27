import 'package:flutter/material.dart';
import 'package:service_provider/screens/appointment_time_slot.dart';
import 'package:service_provider/screens/pin_location.dart';
import 'package:table_calendar/table_calendar.dart';

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
List<String> petsList = []; // List to store pets

class EditProfileScreenState extends State<EditProfileScreen> {
  String dropdownValue = number.first; //dropdown for # of pets catered per day
//Controllers
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
  final TextEditingController doorNoController = TextEditingController();

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

// Method to add pet to the list
  Future<void> _addPet() async {
    String? newPet = await _showAddPetDialog();
    if (newPet != null && newPet.isNotEmpty) {
      setState(() {
        petsList.add(newPet); // Add pet to the list
      });
    }
  }

  // Method to remove a pet from the list
  void _removePet(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: const Text('Are you sure you want to delete this pet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => petsList.removeAt(index)); // Remove pet
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

// Dialog to input pet name
  Future<String?> _showAddPetDialog() async {
    String petCategory = '';
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Pet'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter pet category'),
            onChanged: (value) {
              petCategory = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without returning anything
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(petCategory); // Return entered category
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.profileData != null) {
      establishmentNameController.text =
          widget.profileData?['establishment name'] ?? '';
      timeOpenController.text = widget.profileData?['time open'] ?? '';
      timeCloseController.text = widget.profileData?['time close'] ?? '';
      petsToCaterController.text = widget.profileData?['pets to cater'] ?? '';
      numberOfPetsCaterController.text =
          widget.profileData?['number of pets'] ?? '';
      datePickerController.text = widget.profileData?['date picker'] ?? '';
      exactAddressController.text = widget.profileData?['exact address'] ?? '';
      cityController.text = widget.profileData?['city'] ?? '';
      barangayController.text = widget.profileData?['barangay'] ?? '';
      streetController.text = widget.profileData?['street'] ?? '';
      doorNoController.text = widget.profileData?['door no'] ?? '';
      dropdownValue = widget.profileData?['number of pets'] ?? number.first;
      petsList = widget.profileData?['petsList'] ?? [];
    }
  }

  void saveProfile() {
    final updatedProfile = {
      'establishment name': establishmentNameController.text,
      'time open': timeOpenController.text,
      'time close': timeCloseController.text,
      'pets to cater': petsToCaterController.text,
      'petsList': petsList,
      'number of pets': dropdownValue,
      'date picker': datePickerController.text,
      'exact address': exactAddressController.text,
      'city': cityController.text,
      'barangay': barangayController
          .text, // Used for the service icon in the service screen
      'street': streetController.text,
      'door no': doorNoController.text,
    };
    Navigator.pop(context, updatedProfile);
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
                  "Pets to Cater",
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: petsList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          title: Text(
                            petsList[index],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color.fromRGBO(160, 62, 6, 1),
                            ),
                            onPressed: () {
                              _removePet(index); // Remove pet from the list
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Add more pets button
                ElevatedButton.icon(
                  onPressed: _addPet, // Add pet when pressed
                  icon: const Icon(Icons.add),
                  label: const Text("Add More"),
                  // label: const Text("Add Pet Category"),
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
                return false;
              },
              onDaySelected: (selectedDay, focusedDay) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AppointmentTimeSlotScreen(selectedDate: selectedDay),
                  ),
                );
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  bool isAvailable = _isDayAvailable(day);
                  return Container(
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    margin: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  bool isAvailable = _isDayAvailable(day);
                  return Container(
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    margin: const EdgeInsets.all(4.0),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
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
                Row(
                  children: [
                    Expanded(
                      flex: 2, // Adjust flex to control the width ratio
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Door No.",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: doorNoController,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Exact Address"),
                const SizedBox(height: 20),
                TextField(
                  controller: exactAddressController,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PinAddress()),
                        );
                      },
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
