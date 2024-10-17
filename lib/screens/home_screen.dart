import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/revenue_chart.dart';
import 'package:service_provider/components/most_availed_chart.dart';
import 'package:service_provider/components/annual_appointments_chart.dart';

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
    {'month': 'Jan', 'value': 2000.00},
    {'month': 'Feb', 'value': 5000.00},
    {'month': 'Mar', 'value': 1700.00},
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
      'counts': [50, 30, 40, 20, 60, 70, 80, 90, 10, 20, 50, 60]
    },
  ];
  final List<Map<String, dynamic>> annualAppointmentData = [
    {'month': 'Jan', 'value': 3000.00},
    {'month': 'Feb', 'value': 1500.00},
    {'month': 'Mar', 'value': 1750.00},
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
                store[0],
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
                  AnnualAppointmentsChart(
                    data: data,
                    labels: labels,
                    annualAppointmentData: const [],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
