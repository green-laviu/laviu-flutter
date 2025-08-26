import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/widgets/m_dialog.dart';

class LiveStreamViewerManageSheet extends StatelessWidget {
  final bool isKicked;
  final String nickname;
  final String username;

  const LiveStreamViewerManageSheet({
    super.key,
    required this.isKicked,
    required this.nickname,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final double profileImgSize = 60;

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
              padding: EdgeInsets.all(MSizes.gapM),
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
                              "https://picsum.photos/300",
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
                  SizedBox(width: MSizes.gapM),
                  // 닉네임 + 아이디
                  Text(
                    '$nickname ',
                    style: TextStyle(
                      fontSize: MSizes.fontM,
                      color: MColors.primaryStrong,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '($username)',
                    style: TextStyle(fontSize: MSizes.fontM, color: MColors.textNeutral),
                  ),
                ],
              ),
            ),
            // 채팅금지
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              title: Text(
                '채팅금지',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false, //다이얼로그 밖 탭해도 닫히지 X
                  builder: (BuildContext context) {
                    return MDialog(
                      title: '채팅금지',
                      message: '$nickname($username)님의\n채팅을 금지하시겠어요?\n현재 누적: 0회\n(3회 시 자동 강제퇴장)',
                      primaryText: '채팅금지',
                      primaryColor: MColors.primaryDanger,
                      onPrimaryTap: () {
                        // 채팅금지 로직
                      },
                      secondaryText: '취소',
                      onSecondaryTap: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
            // 강제퇴장
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              title: Text(
                isKicked ? '강제퇴장 취소' : '강제퇴장',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                if (isKicked) {
                  // 강제 퇴장 취소 로직
                  showDialog(
                    context: context,
                    barrierDismissible: false, //다이얼로그 밖 탭해도 닫히지 X
                    builder: (BuildContext context) {
                      return MDialog(
                        title: '강제퇴장 취소',
                        message: '$nickname($username)님의\n 강제퇴장을 취소하시겠어요?',
                        primaryText: '예',
                        primaryColor: MColors.primaryDanger,
                        onPrimaryTap: () {
                          // 강제퇴장 취소 로직
                        },
                        secondaryText: '아니오',
                        onSecondaryTap: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                } else {
                  // 강제 퇴장 로직
                  showDialog(
                    context: context,
                    barrierDismissible: false, //다이얼로그 밖 탭해도 닫히지 X
                    builder: (BuildContext context) {
                      return MDialog(
                        title: '강제퇴장',
                        message: '$nickname($username)님을\n 강제퇴장 하시겠어요?',
                        primaryText: '강제퇴장',
                        primaryColor: MColors.primaryDanger,
                        onPrimaryTap: () {
                          // 강제퇴장 로직
                        },
                        secondaryText: '취소',
                        onSecondaryTap: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
