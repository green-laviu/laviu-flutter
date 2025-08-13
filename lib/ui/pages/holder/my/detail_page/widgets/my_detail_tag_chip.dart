import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class MyDetailTagChip extends StatelessWidget {
  final String label;
  const MyDetailTagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: MColors.transparent,
        border: Border.all(color: MColors.primaryStrong),
        borderRadius: BorderRadius.circular(MSizes.radiusM),
      ),
      child: Text(
        label,
        style: MText.label2Regular(color: MColors.primaryStrong),
      ),
    );
  }
}
