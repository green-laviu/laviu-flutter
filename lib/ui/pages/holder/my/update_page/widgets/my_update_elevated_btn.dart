import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class MyUpdateElevatedBtn extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final VoidCallback onPressed;

  const MyUpdateElevatedBtn({
    super.key,
    required this.text,
    this.isEnabled = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, MSizes.heightButton),
        backgroundColor: isEnabled ? MColors.primaryStrong : MColors.fillStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text, style: MText.button2(color: MColors.white)),
    );
  }
}
