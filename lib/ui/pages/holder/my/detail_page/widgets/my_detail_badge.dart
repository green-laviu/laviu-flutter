import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';

class MyDetailBadge extends StatelessWidget {
  final Color color;
  final String text;

  const MyDetailBadge({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(MSizes.radiusXS),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: MColors.white,
          fontWeight: FontWeight.w900,
          fontSize: MSizes.fontTiny,
        ),
        strutStyle: StrutStyle(
          height: 1.5,
          leading: 0,
          fontSize: MSizes.fontTiny,
          forceStrutHeight: true,
        ),
      ),
    );
  }
}
