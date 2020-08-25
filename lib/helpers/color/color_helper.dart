import 'package:flutter/material.dart';
import 'package:sma/shared/colors.dart';

Color determineColorBasedOnChange(double change) {
  return (change == null || change < 0)
    ? kNegativeColor 
    : kPositiveColor;
}

TextStyle determineTextStyleBasedOnChange(double change) {
  var fontSize = 12.0;
  if (change.abs() > 100000) {
    fontSize = 10.0;
  }
  return change < 0 
    ?  kChange (kNegativeColor, fontSize)
    : kChange (kPositiveColor, fontSize);
}

TextStyle kChange (Color color, double fontSize) => TextStyle(
  color: color,
  fontSize: fontSize,
  fontWeight: FontWeight.w800
);
