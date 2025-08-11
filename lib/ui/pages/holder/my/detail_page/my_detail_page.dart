import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/widgets/my_detail_badge.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/widgets/my_detail_elevated_btn.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/widgets/my_detail_tag_chip.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/my_update_page.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class MyDetailPage extends StatelessWidget {
  const MyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터
    final String? profileImgUrl = "https://picsum.photos/200"; // null이면 기본 아이콘
    // final profileImgUrl = "https://example.com/404.png";
    final bool isLive = true; // 라이브 상태 여부
    final double profileImgSize = 64; // 프로필 이미지 지름
    final double ringWidth = 3; // 라이브 링 두께
    final bool hasProfileImg = profileImgUrl != null && profileImgUrl.trim().isNotEmpty;
    final String? thumbnailUrl = "https://picsum.photos/200/300";

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          // 프로필 영역
          Column(
            children: [
              Row(
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
                  // 오른쪽 - 닉네임 + 팔로잉 + 채널 소개
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 닉네임
                      Text('다승왕박세웅', style: MText.heading2(color: MColors.textStrong)),
                      // 팔로잉
                      Text('팔로잉 0명', style: MText.label2Bold(color: MColors.textNeutral)),
                      // 채널 소개
                      Text('다승왕박세웅님의 채널입니다.', style: MText.label3(color: MColors.textNeutral)),
                    ],
                  ),
                ],
              ),
              // 채널 관리 (유저 정보 수정) 버튼
              MyDetailElevatedBtn(
                icon: Icon(
                  CupertinoIcons.gear,
                  color: MColors.textWhite,
                  size: MSizes.fontXL,
                ),
                text: '채널 관리',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MyUpdatePage()),
                  );
                },
              ),
            ],
          ),
          Divider(),
          // 라이브 영상 영역
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 라벨
              Text('다승왕박세웅님이 방송을 시작했어요!', style: MText.heading4(color: MColors.textStrong)),
              // 영상
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 썸네일
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(MSizes.radiusL),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            thumbnailUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: MColors.backgroundAlternative,
                              alignment: Alignment.center,
                              child: Icon(CupertinoIcons.photo, color: MColors.textAlternative, size: 32),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Row(
                          children: [
                            // LIVE 배지
                            MyDetailBadge(color: MColors.primaryDanger, text: 'LIVE'),
                            // 시청자수 배지
                            MyDetailBadge(color: MColors.fillContrast, text: '6,438명'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 제목
                  Text('패밀리가 떴다 같이보기', style: MText.heading4(color: MColors.textStrong)),

                  // 해시태그 라벨
                  Row(
                    children: [
                      MyDetailTagChip(label: '#토크'),
                      MyDetailTagChip(label: '#같이보기'),
                      MyDetailTagChip(label: '#패밀리가떴다'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: MDevFloatingBtn(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MyUpdatePage()),
          );
        },
        icon: Icons.person,
      ),
    );
  }
}
