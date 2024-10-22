import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/revenue_chart.dart';
import 'package:service_provider/components/most_availed_chart.dart';
import 'package:service_provider/components/annual_appointments_chart.dart';
import 'package:service_provider/components/satisfaction_rating_chart.dart';
import 'package:service_provider/screens/appointments.dart';
import 'package:service_provider/screens/feedbacks.dart';
import 'package:service_provider/screens/services.dart';
import 'package:service_provider/components/year_dropdown.dart';

final List<int> years = [2023, 2024];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required Null Function() onCardTap});

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
    'Upcoming \nAppointments',
    'Cancelled Appointments',
    'Services',
    'Packages',
    'Feedback'
  ];
  void navigateToScreen(String title) {
    if (title == 'Services' || title == 'Packages') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ServicesScreen()),
      );
      return; // Prevents further navigation to AppointmentsScreen
    }

    int initialTabIndex = 0;

    if (title == 'Appointments Today') {
      initialTabIndex = 0; // "Today" tab
    } else if (title == 'Upcoming \nAppointments') {
      initialTabIndex = 1; // "Upcoming" tab
    } else if (title == 'Cancelled Appointments') {
      initialTabIndex = 4; // "Cancelled" tab
    } else if (title == 'Feedback') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FeedbacksScreen()),
      );
      return; // Prevents further navigation to AppointmentsScreen
    }

    // Navigate to AppointmentsScreen if it's an appointment related title
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AppointmentsScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }

  final List<int> notificationCounts = [
    5,
    2,
    0,
    3,
    1,
    4
  ]; //static data for notification
  void updateDataForYear(int year) {
    setState(() {
      selectedYear = year;
    });
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ' Monthly Revenue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      YearDropdown(
                        years: years,
                        initialYear: selectedYear,
                        onYearChanged: updateDataForYear,
                      ),
                    ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ' Most Availed Services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      YearDropdown(
                        years: years,
                        initialYear: selectedYear,
                        onYearChanged: updateDataForYear,
                      ),
                    ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        ' Annual Appointments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      YearDropdown(
                        years: years,
                        initialYear: selectedYear,
                        onYearChanged: updateDataForYear,
                      ),
                    ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Satisfaction Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      YearDropdown(
                        years: years,
                        initialYear: selectedYear,
                        onYearChanged: updateDataForYear,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SatisfactionRatingChart(
                    data: satisfactionData,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5,
            ),
            itemCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  navigateToScreen(cardTitles[index]);
                },
                child: Stack(
                  children: [
                    Card(
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
                          ],
                        ),
                      ),
                    ),
                    //for the norification number.
                    if (notificationCounts[index] > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: badges.Badge(
                          badgeContent: Text(
                            notificationCounts[index].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          badgeStyle:
                              const badges.BadgeStyle(badgeColor: Colors.red),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
