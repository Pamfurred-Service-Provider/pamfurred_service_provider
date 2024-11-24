import 'package:flutter/material.dart';
import 'package:service_provider/screens/appointments.dart';

AppBar appBar(BuildContext context) {
  return AppBar(
    shape: const Border.symmetric(horizontal: BorderSide(width: .1)),
    backgroundColor: Colors.white,
    toolbarHeight: 85,
    leadingWidth: 190,
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(15, 35, 0, 10),
      child: SizedBox(
        child: Image.asset(
          'assets/pamfurred_logo.png',
          fit: BoxFit.fill,
        ),
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 35, 15, 10),
        child: IconButton(
          icon: const Icon(Icons.calendar_month, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const AppointmentsScreen(initialTabIndex: 0)),
            );
          },
        ),
      ),
    ],
  );
}
