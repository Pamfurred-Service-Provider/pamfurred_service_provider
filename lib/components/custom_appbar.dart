import 'package:flutter/material.dart';
// 1) appBar
// Primarily for homescreen

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
