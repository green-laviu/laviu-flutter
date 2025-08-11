import 'package:flutter/material.dart';

/// 앱에서 사용되는 색상 정의
class MColors {
  // 기본 색상
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;

  // 핑크 테마 컬러
  static const primaryBackground = Color(0xFFF9DADA); // 배경 보조
  static const primaryContainer = Color(0xFFF9CACA); // 카드 배경 등
  static const primarySoft = Color(0xFFF9BABA); // 기본 색상보다 연한 톤
  static const primary = Color(0xFFF9AAAA); // 메인 색상
  static const primaryStrong = Color(0xFFF99A9A); // 강조 버튼, 포커스
  static const primaryBold = Color(0xFFF87C7C); // 진한 강조용
  static const primaryAccent = Color(0xFFFF5C5C); // 강한 포인트
  static const primaryDanger = Color(0xFFFF3D3D); // 레드 느낌 강조
  static const error = Color(0xFFFF0000); // 에러 경고

  // 텍스트 색상
  static const textNormal = Color(0xFF171918);
  static const textStrong = Color(0xFF000000);
  static const textNeutral = Color(0xFF565656);
  static const textAlternative = Color(0xFFB4B4B4);
  static const textDisabled = Color(0xFFE0E0E0);
  static const textWhite = Color(0xFFFFFFFF);

  // 선, 테두리 등 색상
  static const lineNormal = Color(0xFFD7D7D7); // 기본 선
  static const lineAlternative = Color(0xFFE0E0E0); // 소프트한 대안 선
  static const lineStrong = Color(0xFFF99A9A); // 강조/포커스 선 (메인 연핑크 계열)
  static const lineDisabled = Color(0xFFF0F0F0); // 비활성 상태 선 (거의 안 보임)
  static const lineDivider = Color(0xFFECECEC); // 리스트/카드 구분선 등

  // 특정 영역을 채우는 색상
  static const fillNormal = Color(0x4DD7D7D7);
  static const fillStrong = Color(0x99BCBCBC);
  static const fillAlternative = Color(0x80F3F3F3);
  static const fillContrast = textNormal; // 라이브 시청자

  // 배경 색상
  static const backgroundNormal = Color(0xFFFFFFFF); // 흰 배경
  static const backgroundAlternative = Color(0xFFF5F5F5); // 보조 배경

  // 회색 계열
  static const darkGrey = Color(0xFF4A4A4A);
  static const grey = Color(0xFF979796);
  static const lightGrey = Color(0xFFCCCCCC);
  static const extraLightGrey = Color(0xFFF5F5F5);
}
