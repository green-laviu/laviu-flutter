import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class MBtn extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;
  final Widget? icon; // 아이콘을 선택적으로 받음
  final bool isFullWidth;

  const MBtn({
    super.key,
    required this.text,
    this.isSelected = true,
    required this.onPressed,
    this.icon,
    this.isFullWidth = true, // 기본은 가로 너비 전체 차지
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: Size(isFullWidth ? double.infinity : 0, 36),
      backgroundColor: isSelected ? MColors.primaryStrong : MColors.fillStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MSizes.radiusM),
      ),
      elevation: 0,
      shadowColor: MColors.transparent,
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(text, style: MText.button2(color: MColors.white)),
        style: buttonStyle,
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(text, style: MText.button2(color: MColors.white)),
      );
    }
  }
}
