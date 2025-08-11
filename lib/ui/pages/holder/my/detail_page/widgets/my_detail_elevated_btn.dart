import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class MyDetailElevatedBtn extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final VoidCallback onPressed;
  final Widget? icon; // 아이콘을 선택적으로 받음

  const MyDetailElevatedBtn({
    super.key,
    required this.text,
    this.isEnabled = true,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 40), // MSizes.heightButton
      backgroundColor: isEnabled ? MColors.primaryStrong : MColors.fillStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MSizes.radiusM),
      ),
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
