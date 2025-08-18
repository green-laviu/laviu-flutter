import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class MUserInfo extends StatelessWidget {
  const MUserInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(MSizes.gapL, MSizes.gapM, MSizes.gapL, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.fromLTRB(MSizes.gapM, MSizes.gapM, MSizes.gapM, MSizes.gapM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('채널 소개', style: MText.heading4(color: MColors.textStrong)),
                  SizedBox(height: MSizes.gapS),
                  Text(
                    '다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.',
                    softWrap: true,
                    style: MText.label3(color: MColors.textNeutral),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
