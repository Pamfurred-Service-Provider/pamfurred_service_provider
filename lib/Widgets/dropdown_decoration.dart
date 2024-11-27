// A reusable helper function for dropdown styling
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:service_provider/components/globals.dart';

CustomDropdownDecoration getDropdownDecoration() {
  return CustomDropdownDecoration(
    closedFillColor: Color.fromARGB(18, 247, 222, 222),
    expandedFillColor: Colors.white,
    closedSuffixIcon: const Icon(Icons.arrow_drop_down),
    expandedSuffixIcon: const Icon(Icons.arrow_drop_up),
    closedBorder: Border.all(color: Colors.black, width: .8),
    closedBorderRadius: BorderRadius.circular(secondaryBorderRadius),
    closedErrorBorder: Border.all(color: Colors.red),
    closedErrorBorderRadius: BorderRadius.circular(secondaryBorderRadius),
    expandedBorder: Border.all(color: primaryColor, width: .15),
    expandedBorderRadius: BorderRadius.circular(secondaryBorderRadius),
    hintStyle: const TextStyle(color: greyColor, fontSize: regularText),
    noResultFoundStyle:
        const TextStyle(color: Colors.red, fontSize: regularText),
    errorStyle: const TextStyle(color: Colors.red, fontSize: regularText),
    listItemStyle: const TextStyle(color: Colors.black, fontSize: regularText),
    overlayScrollbarDecoration: const ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(lightGreyColor),
    ),
  );
}
