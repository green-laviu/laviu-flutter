import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MIcons {
  static Widget loginNaverLogo({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.asset(
      'assets/icons/login_naver_logo.svg',
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}
