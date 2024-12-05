import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/screens/appointments.dart';

// 1) appBar
// Primarily for homescreen
// Custom AppBar for other screens
AppBar HomeAppBar(BuildContext context) {
  return AppBar(
    shape: const Border.symmetric(horizontal: BorderSide(width: 0.1)),
    backgroundColor: Colors.white,
    toolbarHeight: 85, // Adjusted height
    leadingWidth: 190, // Increased leading width
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(15, 35, 0, 10),
      child: Image.asset(
        'assets/pamfurred_logo.png', // Replace with your logo asset
        fit: BoxFit.fill,
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

// 2) customAppBar
// This is for other screens but homescreen
AppBar customAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    toolbarHeight: 60,
    actions: <Widget>[Container()],
    leading: Padding(
      padding: const EdgeInsets.all(10.0),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          // Custom action on back button press
          Navigator.pop(context);
        },
      ),
    ),
  );
}

// 3) customAppBar with Title
// This is for other screens but homescreen
AppBar customAppBarWithTitle(BuildContext context, String title) {
  return AppBar(
    backgroundColor: lighterGreyColor,
    toolbarHeight: 70,
    title: Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        title,
        style: TextStyle(),
      ),
    ),
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: Color.fromARGB(255, 0, 0, 0)),
        onPressed: () {
          // Custom action on back button press
          Navigator.pop(context);
        },
      ),
    ),
  );
}

// 4) customAppBar with action
AppBar customAppBarWithTitleAndWidget(
    BuildContext context, String title, List<Widget> actions) {
  return AppBar(
    backgroundColor: Colors.white,
    toolbarHeight: 70,
    title: Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(title),
    ),
    leading: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {
          // Custom action on back button press
          Navigator.pop(context);
        },
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(
            right: 20.0), // Adjust the right padding as needed
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Ensures that the actions stay compact
          children: actions,
        ),
      ),
    ],
  );
}
