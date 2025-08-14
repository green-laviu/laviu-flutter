import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class MFpsSheet extends StatelessWidget {
  const MFpsSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          top: MSizes.gapM,
          bottom: MediaQuery.of(context).padding.bottom + MSizes.gapM,
          left: MSizes.gapL,
          right: MSizes.gapL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Padding(
              padding: EdgeInsets.symmetric(vertical: MSizes.gapS),
              child: Text(
                '프레임 속도',
                style: MText.heading3Bold(color: MColors.textNormal),
              ),
            ),
            // 60fps
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              title: Text(
                '60fps',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.check, color: MColors.textNormal),
              onTap: () {},
            ),
            // 30fps
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              title: Text(
                '30fps',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              trailing: Icon(Icons.check, color: MColors.textNormal),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
