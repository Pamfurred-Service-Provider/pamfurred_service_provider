import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/revenue_chart.dart';
import 'package:service_provider/components/most_availed_chart.dart';
import 'package:service_provider/components/annual_appointments_chart.dart';
import 'package:service_provider/components/satisfaction_rating_chart.dart';
import 'package:service_provider/screens/appointments.dart';
import 'package:service_provider/screens/feedbacks.dart';
import 'package:service_provider/screens/services.dart';

final List<int> years = [2023, 2024];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedYear = years.first;

  // Static Data
  final List<String> store = [
    'Paws and Claws Pet Station',
    'Groomers on the Go'
  ];
  final List<Map<String, dynamic>> revenueData = [
    {'month': 'Jan', 'value': 2500.00},
    {'month': 'Feb', 'value': 5000.00},
    {'month': 'Mar', 'value': 1000.00},
    {'month': 'Apr', 'value': 2000.00},
    {'month': 'May', 'value': 3000.00},
    {'month': 'Jun', 'value': 4080.00},
    {'month': 'Jul', 'value': 5480.00},
    {'month': 'Aug', 'value': 5050.00},
    {'month': 'Sep', 'value': 6540.00},
    {'month': 'Oct', 'value': 7000.00},
    {'month': 'Nov', 'value': 8000.00},
    {'month': 'Dec', 'value': 3152.00},
  ];
  final List<Map<String, dynamic>> mostAvailedData = [
    {
      'service': 'Nail Clipping',
      'counts': [50, 30, 40, 20, 60, 70, 80, 90, 10, 20, 50, 60]
    }, // Monthly counts of service availed
    {
      'service': 'Hair Color',
      'counts': [50, 10, 30, 15, 25, 35, 45, 55, 25, 35, 45, 55]
    },
    {
      'service': 'Bathe',
      'counts': [30, 10, 30, 15, 25, 35, 15, 55, 25, 35, 45, 8]
    },
    {
      'service': 'Oral Care',
      'counts': [50, 35, 40, 20, 60, 70, 80, 90, 10, 20, 50, 60]
    },
  ];
  final List<Map<String, dynamic>> annualAppointmentData = [
    {'month': 'Jan', 'value': 3000.00},
    {'month': 'Feb', 'value': 1000.00},
    {'month': 'Mar', 'value': 5000.00},
    {'month': 'Apr', 'value': 2000.00},
    {'month': 'May', 'value': 3000.00},
    {'month': 'Jun', 'value': 4080.00},
    {'month': 'Jul', 'value': 5480.00},
    {'month': 'Aug', 'value': 1080.00},
    {'month': 'Sep', 'value': 6540.00},
    {'month': 'Oct', 'value': 6540.00},
    {'month': 'Nov', 'value': 8000.00},
    {'month': 'Dec', 'value': 8000.00},
  ];
  final List<Map<String, dynamic>> satisfactionData = [
    {
      'label': 'Satisfied',
      'value': 95.0,
      'color': const Color.fromRGBO(251, 188, 4, 1)
    },
    {
      'label': 'Neutral',
      'value': 2.0,
      'color': const Color.fromRGBO(102, 22, 22, 1)
    },
    {
      'label': 'Negative',
      'value': 2.5,
      'color': const Color.fromRGBO(255, 0, 0, 1)
    },
  ];
  final List<String> cardTitles = [
    'Appointments \nToday',
    'Pending \nAppointments',
    'Cancelled Appointments',
    'Services',
    'Packages',
    'Feedback'
  ];
  void navigateToScreen(String title) {
    if (title == 'Appointments Today') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
      );
    } else if (title == 'Pending Appointments') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
      );
    } else if (title == 'Cancelled Appointments') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppointmentsScreen()),
      );
    } else if (title == 'Services') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ServicesScreen()),
      );
    } else if (title == 'Packages') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ServicesScreen()),
      );
    } else if (title == 'Feedback') {
      // You can navigate to a feedback screen or another screen for feedback
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeedbacksScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<double> data =
        revenueData.map((e) => e['value'] as double).toList();
    final List<String> labels =
        revenueData.map((e) => e['month'] as String).toList();
    return Scaffold(
      appBar: appBar(context),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(
                  color: Color(0xFF651616),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                store[1],
                style: const TextStyle(
                  color: Color(0xFF651616),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ' Monthly Revenue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RevenueChart(
                    data: data,
                    labels: labels,
                    revenueData: const [],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ' Most Availed Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MostAvailedChart(
                    data: mostAvailedData, // Pass the data for stacking
                    labels: labels,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    ' Annual Appointments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnnualAppointmentsChart(
                    data: data,
                    labels: labels,
                    annualAppointmentData: const [],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15), // Padding inside the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Satisfaction Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SatisfactionRatingChart(
                    data: satisfactionData,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16,
            ),
            itemCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  navigateToScreen(cardTitles[index]);
                },
                child: Card(
                  color: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              cardTitles[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Align(
                        //   alignment: Alignment.topRight,
                        //   child: Container(
                        //     padding: const EdgeInsets.all(4),
                        //     decoration: BoxDecoration(
                        //       color: Colors.red,
                        //       borderRadius: BorderRadius.circular(12),
                        //     ),
                        //     child: const Text(
                        //       '10', // Notification number
                        //       style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
