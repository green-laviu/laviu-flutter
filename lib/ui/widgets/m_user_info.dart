import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/model/user.dart';

class MUserInfo extends StatelessWidget {
  final User user;

  const MUserInfo(this.user, {super.key});

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
              padding: EdgeInsets.fromLTRB(
                MSizes.gapM,
                MSizes.gapM,
                MSizes.gapM,
                MSizes.gapM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '채널 소개',
                    style: MText.heading4(color: MColors.textStrong),
                  ),
                  SizedBox(height: MSizes.gapS),
                  Text(
                    '${user.bio}',
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
