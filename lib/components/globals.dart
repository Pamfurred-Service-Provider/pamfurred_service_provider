import 'package:flutter/material.dart';

// fontSize
const double smallText = 13;
const double regularText = 15;
const double headerText = 25;
const double titleFont = 18;

// fontWeight
const regularWeight = FontWeight.w100;
const boldWeight = FontWeight.w900;
const mediumWeight = FontWeight.w600;

// Colors
const primaryColor = Color.fromRGBO(160, 62, 6, 1.0);
const lighterPrimaryColor = Color.fromRGBO(255, 94, 0, 1);
const secondaryColor = Color.fromRGBO(255, 137, 29, 1.0);
const lighterSecondaryColor = Color.fromRGBO(255, 246, 228, 1);
const greyColor = Color.fromRGBO(83, 83, 83, 1);
const secondaryGreyColor = Colors.black45;
const lightGreyColor = Color.fromRGBO(241, 241, 241, 1);
const lighterGreyColor = Color.fromRGBO(244, 244, 244, 1);
const mediumGreyColor = Color.fromRGBO(165, 165, 165, 1);
const lightRedColor = Color.fromRGBO(255, 214, 191, 1);
const tangerine = Color.fromRGBO(209, 76, 1, 1);
const darkGreyColor = Color.fromARGB(255, 51, 51, 51);
const disabledButtonTextColor = Color.fromARGB(255, 161, 159, 159);

// Screen width
double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

// Screen height
double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

// Textfields/Textformfields
const double primaryTextFieldHeight = 40;

// Padding
const primaryPadding = EdgeInsets.fromLTRB(35, 0, 35, 0);

// Overall screen padding
double screenPadding(BuildContext context) {
  return MediaQuery.of(context).size.width - 45;
}

// SizedBox
const double primarySizedBox = 4;
const double secondarySizedBox = 8;
const double tertiarySizedBox = 16;
const double quaternarySizedBox = 24;

// BorderRadius
const double primaryBorderRadius = 5;
const double secondaryBorderRadius = 10;
const double tertiaryBorderRadius = 15;
const double quaternaryBorderRadius = 20;

// Variables requiring device width
double deviceWidthDivideOnePointFive(BuildContext context) {
  return MediaQuery.of(context).size.width / 1.5;
}

// Utility function to convert a string to lowercase
String toLowercase(String text) {
  return text.toLowerCase();
}
