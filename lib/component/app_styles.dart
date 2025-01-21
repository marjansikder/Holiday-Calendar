import 'package:flutter/material.dart';

import 'app_colors.dart';

TextStyle getCustomTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.normal,
  Color color = AppColors.blackColor,
  double height = 1.5,
  String fontFamily = 'Watford',
  FontStyle fontStyle = FontStyle.normal,
  TextDecoration decoration = TextDecoration.none,
  double? letterSpacing,
  double? wordSpacing,
}) {
  return TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    fontFamily: fontFamily.isNotEmpty ? fontFamily : 'Watford',
    fontStyle: fontStyle,
    decoration: decoration,
    letterSpacing: letterSpacing,
    wordSpacing: wordSpacing,
  );
}
