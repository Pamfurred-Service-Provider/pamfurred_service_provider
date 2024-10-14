import 'package:flutter/material.dart';
import 'package:service_provider/components/custom_appbar.dart';

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
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 388,
                      height: 267,
                      decoration: ShapeDecoration(
                        color: Color(0xFFFFFDF9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 310,
                    top: 31,
                    child: Container(
                      width: 53,
                      height: 22,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7)),
                      ),
                      child: DropdownButton<int>(
                        value: selectedYear,
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedYear = newValue!;
                          });
                        },
                        items: years.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(
                              year.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 42,
                    top: 35,
                    bottom: 35,
                    child: SizedBox(
                      width: 154,
                      height: 14,
                      child: Text(
                        'Sales Revenue',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 26,
                    top: 78,
                    child: Container(
                      width: 334,
                      height: 158,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 27,
                            top: 146,
                            child: Text(
                              'Jan   Feb   Mar   Apr   May   Jun   Jul   Aug   Sep   Oct   Nov   Dec',
                              style: TextStyle(
                                color: Color(0xFF2E2E30),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: 3,
                            child: Container(
                              width: 26,
                              height: 134.11,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 52,
                                    child: SizedBox(
                                      width: 22,
                                      height: 9,
                                      child: Text(
                                        '30K',
                                        style: TextStyle(
                                          color: Color(0xFF2E2E30),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: SizedBox(
                                      width: 22,
                                      height: 9,
                                      child: Text(
                                        '50K',
                                        style: TextStyle(
                                          color: Color(0xFF2E2E30),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 26,
                                    child: SizedBox(
                                      width: 22,
                                      height: 9,
                                      child: Text(
                                        '40K',
                                        style: TextStyle(
                                          color: Color(0xFF2E2E30),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 78,
                                    child: SizedBox(
                                      width: 26,
                                      height: 9,
                                      child: Text(
                                        '20K',
                                        style: TextStyle(
                                          color: Color(0xFF2E2E30),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 104,
                                    child: SizedBox(
                                      width: 22,
                                      height: 9,
                                      child: Text(
                                        '10K',
                                        style: TextStyle(
                                          color: Color(0xFF2E2E30),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 125,
                                    child: SizedBox(
                                      width: 7,
                                      height: 9.11,
                                      child: Text(
                                        '0',
                                        style: TextStyle(
                                          color: Color(0xFF2E2E30),
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 26,
                            top: 79,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 59,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 78,
                            top: 60,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 78,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 52,
                            top: 71,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 67,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 52,
                            top: 72,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 78,
                            top: 62,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 104,
                            top: 30,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 130,
                            top: 31,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 156,
                            top: 22,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 182,
                            top: 7,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 208,
                            top: 2,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 234,
                            top: 11,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 260,
                            top: 7,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 286,
                            top: 22,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 312,
                            top: 35,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 104,
                            top: 29,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 109,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 156,
                            top: 20,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 118,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 130,
                            top: 31,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 107,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 182,
                            top: 6,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 132,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 234,
                            top: 10,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 128,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 208,
                            top: 0,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 138,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 260,
                            top: 5,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 135,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 312,
                            top: 33,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 107,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 286,
                            top: 20,
                            child: Opacity(
                              opacity: 0.10,
                              child: Container(
                                width: 22,
                                height: 120,
                                decoration:
                                    BoxDecoration(color: Color(0xFFD14C01)),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 26,
                            top: 80,
                            child: Container(
                              width: 22,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                    color: Color(0xFFD14C01),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
