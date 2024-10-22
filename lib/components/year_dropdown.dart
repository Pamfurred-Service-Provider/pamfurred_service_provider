import 'package:flutter/material.dart';

class YearDropdown extends StatefulWidget {
  final List<int> years;
  final int initialYear;
  final Function(int) onYearChanged;

  const YearDropdown({
    super.key,
    required this.years,
    required this.initialYear,
    required this.onYearChanged,
  });

  @override
  YearDropdownState createState() => YearDropdownState();
}

class YearDropdownState extends State<YearDropdown> {
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: selectedYear,
      items: widget.years.map((int year) {
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
      onChanged: (int? newYear) {
        setState(() {
          selectedYear = newYear!;
          widget.onYearChanged(selectedYear);
        });
      },
    );
  }
}
