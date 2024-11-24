import 'package:flutter/material.dart';
import 'package:service_provider/screens/notification_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  String? serviceProviderId;
  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final supabase = Supabase.instance.client;
    final serviceSession = supabase.auth.currentSession;

    if (serviceSession == null) {
      throw Exception("User not logged in");
    }
    final userId = serviceSession.user.id;
    print('User ID: $userId');

    // Fetch the service provider ID (sp_id) using user_id
    final spResponse = await supabase
        .from('service_provider')
        .select('sp_id')
        .eq('sp_id', userId)
        .single();

    if (spResponse == null || spResponse['sp_id'] == null) return;

    setState(() {
      serviceProviderId = spResponse['sp_id'];
    });
  }

  Future<List<Map<String, dynamic>>> fetchAppointmentDetails() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.rpc(
      'get_appointment_details_by_sp_id',
      params: {'sp_id_param': serviceProviderId},
    );

    final dataList = List<Map<String, dynamic>>.from(response);
    // Group the data by appointment ID
    final groupedData = groupAppointmentData(dataList);

    return groupedData;
  }

  List<Map<String, dynamic>> groupAppointmentData(
      List<Map<String, dynamic>> dataList) {
    final groupedData = <String, Map<String, dynamic>>{};

    for (var item in dataList) {
      final appointmentId = item['appointment_id'];
      if (!groupedData.containsKey(appointmentId)) {
        groupedData[appointmentId] = {
          ...item,
          'services': [],
          'packages': [],
        };
      }

      if (item['service_name'] != null) {
        groupedData[appointmentId]!['services'].add({
          'name': item['service_name'],
          'price': item['service_price'],
        });
      }

      if (item['package_name'] != null) {
        groupedData[appointmentId]!['packages'].add({
          'name': item['package_name'],
          'price': item['package_price'],
          'inclusions': item['package_inclusions'],
        });
      }
    }

    return groupedData.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> todayAppointments = [
      {
        'id': '1445547gg5fg1',
        'date': 'January 2, 2024',
        'name': 'Bob Niño Golosinda',
        'time': '09:00 AM - 11:00 AM',
        'status': 'Pending',
        'phone': '09945876258',
        'category': 'Dog',
        'type': 'Pet Salon',
        'total': '350.00',
        'services': [
          {'service': 'Nail Clipping', 'price': '100.00'},
          {'service': 'Haircut', 'price': '250.00'},
        ],
      },
      {
        'name': 'Lynie Rose Gaa',
        'date': 'January 2, 2024',
        'time': '11:00 AM',
        'status': 'Pending',
        'phone': '09945876258',
        'category': 'Dog',
        'type': 'Pet Salon',
        'availed': 'Nail Clipping',
        'price': '100.00'
      },
    ];

    final List<Map<String, String>> earlierAppointments = [
      {'name': 'Aillen Gonzaga', 'date': 'January 1, 2024', 'time': '01:00 PM'},
      {'name': 'Arny Ucab', 'date': 'December 31, 2023', 'time': '03:00 PM'},
    ];

    return Scaffold(
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Today",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(160, 62, 6, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...todayAppointments
              .map((appointment) => buildAppointmentCard(appointment)),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Earlier",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(160, 62, 6, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...earlierAppointments
              .map((appointment) => buildAppointmentCard(appointment))
        ],
      ),
    );
  }

  Widget buildAppointmentCard(Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () {
        // Navigate to the NotificationDetailsScreen with the selected appointment
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NotificationDetailsScreen(appointment: appointment),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8), // Adds padding on all sides
            child: Card(
              color: Colors.white,
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['date']!,
                          ),
                          Text(
                            appointment['time']!,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            appointment['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            indent: 16.0,
            endIndent: 16.0,
          ),
        ],
      ),
    );
  }
}
