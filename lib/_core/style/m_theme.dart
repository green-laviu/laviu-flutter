import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

ThemeData mTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: MColors.primary,
    scaffoldBackgroundColor: MColors.backgroundNormal,
    appBarTheme: AppBarTheme(
      backgroundColor: MColors.backgroundNormal,
      titleTextStyle: MText.heading2(color: MColors.textNormal),
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: MColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MSizes.cardRadius),
      ),
      elevation: 5,
      margin: EdgeInsets.all(MSizes.gapM),
    ),
    dividerTheme: DividerThemeData(
      thickness: MSizes.dividerThickness,
      color: MColors.lineNormal,
    ),
    textTheme: GoogleFonts.notoSansTextTheme(),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MColors.backgroundNormal,
      type: BottomNavigationBarType.fixed,
      // selectedItemColor: MColors.primaryStrong,
      // unselectedItemColor: MColors.textNeutral,
      // selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      // unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MSizes.buttonRadius),
      ),
      buttonColor: MColors.primaryStrong,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MSizes.radiusM),
        borderSide: BorderSide(color: MColors.lineNormal),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM, vertical: MSizes.gapS),
      hintStyle: TextStyle(fontSize: 14, color: MColors.textDisabled),
    ),
  );
}
