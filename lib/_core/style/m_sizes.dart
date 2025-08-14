import 'package:flutter/material.dart';

// 사이즈 상수 정의
class MSizes {
  // Gap constants
  static const double gapXS = 2.0;
  static const double gapS = 5.0;
  static const double gapM = 10.0;
  static const double gapL = 16.0;
  static const double gapXL = 20.0;
  static const double gapXXL = 24.0;
  static const double gapHuge = 32.0;

  // Radius constants
  static const double radiusXS = 4.0;
  static const double radiusS = 6.0;
  static const double radiusM = 8.0;
  static const double radiusL = 10.0;
  static const double radiusXL = 12.0;
  static const double radiusXXL = 15.0;
  static const double radiusHuge = 20.0;
  static const double radiusCircle = 50.0;

  // Card/Button/Tag radius
  static const double cardRadius = radiusM;
  static const double buttonRadius = radiusXL;
  static const double tagRadius = radiusXXL;

  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;

  // Font sizes (for reference)
  static const double fontTiny = 10.0;
  static const double fontXS = 11.0;
  static const double fontS = 12.0;
  static const double fontNormal = 14.0;
  static const double fontM = 16.0;
  static const double fontL = 18.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;
  static const double fontHuge = 64.0;

  // Heights/Widths
  static const double heightButton = 48.0;
  static const double heightInput = 44.0;
  static const double heightCard = 140.0;
  static const double widthButton = double.infinity;

  // Animation durations
  static const Duration animDurationFast = Duration(milliseconds: 200);
  static const Duration animDurationNormal = Duration(milliseconds: 400);
  static const Duration animDurationMedium = Duration(milliseconds: 600);
  static const Duration animDurationSlow = Duration(milliseconds: 800);

  // Divider/Line
  static const double dividerThickness = 1.0;
  static const double dividerThick = 15.0;

  // Utility functions
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getDrawerWidth(BuildContext context) {
    return getScreenWidth(context) * 0.6;
  }
}
