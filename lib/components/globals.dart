import 'package:flutter/material.dart';

// fontSize
const double regularText = 15;
const double headerText = 18;
const double titleFont = 25;

// fontWeight
const boldWeight = FontWeight.w900;
const mediumWeight = FontWeight.w600;

// Colors
const primaryColor = Color.fromRGBO(160, 62, 6, 1.0);
const secondaryColor = Color.fromRGBO(255, 137, 29, 1.0);
const greyColor = Color.fromRGBO(83, 83, 83, 1);
const lightGreyColor = Color.fromRGBO(241, 241, 241, 1);

// Textfields/Textformfields
const double primaryTextFieldHeight = 40;

// Padding
const primaryPadding = EdgeInsets.fromLTRB(35, 0, 35, 0);

// Overall screen padding
double screenPadding(BuildContext context) {
  return MediaQuery.of(context).size.width - 40;
}

// SizedBox
const double primarySizedBox = 4;
const double secondarySizedBox = 8;
const double tertiarySizedBox = 16;
const double quaternarySizedBox = 24;

// BorderRadius
const double primaryBorderRadius = 5;
const double secondaryBorderRadius = 10;

// Variables requiring device width
double deviceWidthDivideOnePointFive(BuildContext context) {
  return MediaQuery.of(context).size.width / 1.5;
}
