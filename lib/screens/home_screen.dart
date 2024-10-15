import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/revenue_chart.dart';

final List<int> years = [2023, 2024];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedYear = years.first;

  //Static Data
  final List<String> store = [
    'Paws and Claws Pet Station',
    'Groomers on the Go'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
              ],
            ),
          ),
          Center(
            child: Container(
              width: 388,
              height: 267,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
                borderRadius:
                    BorderRadius.all(Radius.circular(15)), // Rounded shadow
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFFFFFDF9), // Background color for the card
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: RevenueChart(
                      data: [
                        10,
                        20,
                        30,
                        40,
                        50,
                        60,
                        70,
                        80,
                        90,
                        100,
                        100,
                        100
                      ], //x data
                      labels: [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sept',
                        'Oct',
                        'Nov',
                        'Dec'
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
