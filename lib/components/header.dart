import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';

Widget buildSectionHeader(String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: secondarySizedBox),
      Text(
        title,
        style: const TextStyle(
            fontSize: headerText,
            fontWeight: mediumWeight,
            color: primaryColor),
      ),
    ],
  );
}

Widget buildSectionHeaderBlackText(String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: secondarySizedBox),
      Text(
        title,
        style: const TextStyle(
            fontSize: headerText,
            fontWeight: mediumWeight,
            color: Colors.black),
      ),
    ],
  );
}
