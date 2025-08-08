import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';

class MText {
  // Heading
  static TextStyle heading1({Color? color}) =>
      TextStyle(fontSize: MSizes.fontXXL, fontWeight: FontWeight.w700, color: color);
  static TextStyle heading2({Color? color}) =>
      TextStyle(fontSize: MSizes.fontXL, fontWeight: FontWeight.w700, color: color);
  static TextStyle heading3Bold({Color? color}) =>
      TextStyle(fontSize: MSizes.fontL, fontWeight: FontWeight.w700, color: color);
  static TextStyle heading3SemiBold({Color? color}) =>
      TextStyle(fontSize: MSizes.fontL, fontWeight: FontWeight.w600, color: color);
  static TextStyle heading4({Color? color}) =>
      TextStyle(fontSize: MSizes.fontXS, fontWeight: FontWeight.w500, color: color);

  // Input
  static TextStyle inputMedium({Color? color}) =>
      TextStyle(fontSize: MSizes.fontM, fontWeight: FontWeight.w500, color: color);
  static TextStyle inputRegular({Color? color}) =>
      TextStyle(fontSize: MSizes.fontM, fontWeight: FontWeight.w400, color: color);

  // Label
  static TextStyle label1SemiBold({Color? color}) =>
      TextStyle(fontSize: MSizes.fontNormal, fontWeight: FontWeight.w600, color: color);
  static TextStyle label1Medium({Color? color}) =>
      TextStyle(fontSize: MSizes.fontNormal, fontWeight: FontWeight.w500, color: color);
  static TextStyle label2Bold({Color? color}) =>
      TextStyle(fontSize: MSizes.fontS, fontWeight: FontWeight.w700, color: color);
  static TextStyle label2Medium({Color? color}) =>
      TextStyle(fontSize: MSizes.fontS, fontWeight: FontWeight.w500, color: color);
  static TextStyle label2Regular({Color? color}) =>
      TextStyle(fontSize: MSizes.fontS, fontWeight: FontWeight.w400, color: color);
  static TextStyle label3({Color? color}) =>
      TextStyle(fontSize: MSizes.fontXS, fontWeight: FontWeight.w500, color: color);

  // Button
  static TextStyle button1({Color? color}) =>
      TextStyle(fontSize: MSizes.fontXL, fontWeight: FontWeight.w700, color: color);
  static TextStyle button2({Color? color}) =>
      TextStyle(fontSize: MSizes.fontL, fontWeight: FontWeight.w700, color: color);
  static TextStyle button3({Color? color}) =>
      TextStyle(fontSize: MSizes.fontM, fontWeight: FontWeight.w500, color: color);
  static TextStyle button4Medium({Color? color}) =>
      TextStyle(fontSize: MSizes.fontNormal, fontWeight: FontWeight.w500, color: color);
  static TextStyle button4Regular({Color? color}) =>
      TextStyle(fontSize: MSizes.fontNormal, fontWeight: FontWeight.w400, color: color);
  static TextStyle button5Bold({Color? color}) =>
      TextStyle(fontSize: MSizes.fontS, fontWeight: FontWeight.w700, color: color);
  static TextStyle button5SemiBold({Color? color}) =>
      TextStyle(fontSize: MSizes.fontS, fontWeight: FontWeight.w600, color: color);

  // Modal
  static TextStyle modal1({Color? color}) =>
      TextStyle(fontSize: MSizes.fontL, fontWeight: FontWeight.w600, color: color);
  static TextStyle modal2Medium({Color? color}) =>
      TextStyle(fontSize: MSizes.fontM, fontWeight: FontWeight.w500, color: color);
  static TextStyle modal2Regular({Color? color}) =>
      TextStyle(fontSize: MSizes.fontM, fontWeight: FontWeight.w400, color: color);
  static TextStyle modal3Bold({Color? color}) =>
      TextStyle(fontSize: MSizes.fontNormal, fontWeight: FontWeight.w700, color: color);
  static TextStyle modal3Medium({Color? color}) =>
      TextStyle(fontSize: MSizes.fontNormal, fontWeight: FontWeight.w500, color: color);
  static TextStyle modal3Regular({Color? color}) =>
      TextStyle(fontSize: MSizes.fontNormal, fontWeight: FontWeight.w400, color: color);

  // Validation / Caption
  static TextStyle caption({Color? color}) =>
      TextStyle(fontSize: MSizes.fontS, fontWeight: FontWeight.w400, color: color);
  static TextStyle validation({Color? color}) =>
      TextStyle(fontSize: MSizes.fontS, fontWeight: FontWeight.w500, color: color);
}
