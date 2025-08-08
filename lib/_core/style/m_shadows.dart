import 'package:flutter/material.dart';

class MShadows {
  static const List<BoxShadow> shadowNormal = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 1,
      offset: Offset(0, 0),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowEmphasize = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 4,
      offset: Offset(0, 0),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 12,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowStrong = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 0),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 20,
      offset: Offset(0, 16),
      spreadRadius: 0,
    ),
  ];
}
