import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/widgets/my_detail_badge.dart';

class ProfileRow extends StatelessWidget {
  const ProfileRow({super.key});

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터
    final String? profileImgUrl = "https://picsum.photos/200"; // null이면 기본 아이콘
    // final profileImgUrl = "https://example.com/404.png";
    final bool isLive = true; // 라이브 상태 여부
    final double profileImgSize = 64; // 프로필 이미지 지름
    final double ringWidth = 3; // 라이브 링 두께
    final bool hasProfileImg = profileImgUrl != null && profileImgUrl.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 왼쪽 - 프로필 이미지
        isLive
            ? Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(ringWidth),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          MColors.primarySoft,
                          MColors.primary,
                          MColors.primaryStrong,
                          MColors.primaryBold,
                          MColors.primaryAccent,
                          MColors.primaryBold,
                          MColors.primaryStrong,
                          MColors.primary,
                          MColors.primarySoft,
                        ],
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(ringWidth),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MColors.white,
                      ),
                      child: ClipOval(
                        child: Container(
                          width: profileImgSize,
                          height: profileImgSize,
                          color: MColors.fillNormal, // fillNormal transparent
                          child: hasProfileImg
                              ? Image.network(
                                  profileImgUrl,
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
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    child: MyDetailBadge(
                      color: MColors.primaryDanger,
                      text: 'LIVE',
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: profileImgSize + ringWidth * 4,
                height: profileImgSize + ringWidth * 4,
                child: Center(
                  child: ClipOval(
                    child: Container(
                      width: profileImgSize,
                      height: profileImgSize,
                      color: MColors.fillNormal, // fillNormal transparent
                      child: hasProfileImg
                          ? Image.network(
                              profileImgUrl,
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
                ),
              ),
        SizedBox(width: MSizes.gapL),
        // 오른쪽 - 닉네임 + 팔로잉 + 채널 소개
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 닉네임
              Text('다승왕박세웅', style: MText.heading2(color: MColors.textStrong)),
              SizedBox(height: MSizes.gapXS),
              // 팔로잉
              Text('팔로잉 0명', style: MText.label2Bold(color: MColors.textNeutral)),
              SizedBox(height: MSizes.gapXS),
              // 채널 소개
              Builder(
                builder: (tabContext) => InkWell(
                  onTap: () {
                    DefaultTabController.of(tabContext).animateTo(1);
                  }, // "정보" 탭으로 전환
                  child: Text(
                    '다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.다승왕박세웅님의 채널입니다.',
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MText.label3(color: MColors.textNeutral),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
