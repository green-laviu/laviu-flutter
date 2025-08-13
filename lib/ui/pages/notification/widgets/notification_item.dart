import 'package:flutter/cupertino.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({super.key});

  @override
  Widget build(BuildContext context) {
    final double profileImgSize = 64;

    return Padding(
      padding: EdgeInsets.fromLTRB(MSizes.gapL, MSizes.gapM, MSizes.gapL, MSizes.gapM),
      child: Row(
        children: [
          // 프로필 이미지
          ClipOval(
            child: Container(
              width: profileImgSize,
              height: profileImgSize,
              color: MColors.fillNormal,
              child:
                  true // hasProfileImg
                  ? Image.network(
                      "https://picsum.photos/200",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        CupertinoIcons.person,
                        color: MColors.fillStrong,
                        size: profileImgSize * 0.8,
                      ),
                    )
                  : Icon(
                      CupertinoIcons.person,
                      color: MColors.fillStrong,
                      size: profileImgSize * 0.8,
                    ),
            ),
          ),
          SizedBox(width: MSizes.gapL),
          // 알림 내용 + 라이브 제목 + 날짜
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '다승왕박세웅...님의 라이브가 시작했어요',
                style: MText.label2Medium(color: MColors.textNormal),
              ),
              Text(
                '라이브 제목',
                style: TextStyle(
                  color: MColors.textStrong,
                  fontSize: MSizes.fontM,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '25.08.11',
                style: MText.label2Medium(color: MColors.textNormal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
