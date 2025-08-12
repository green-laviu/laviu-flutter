import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/widgets/m_btn.dart';
import 'package:laviu_flutter/ui/widgets/m_info.dart';
import 'package:laviu_flutter/ui/widgets/m_live.dart';
import 'package:laviu_flutter/ui/widgets/m_profile_row.dart';

class UserDetailBody extends StatelessWidget {
  const UserDetailBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isFollowing = false;
    final bool isNotiOn = false; // 알림 꺼짐이면 false

    return Column(
      children: [
        // 탭바 위 헤더 (프로필 + 버튼)
        Padding(
          padding: EdgeInsets.fromLTRB(MSizes.gapL, MSizes.gapM, MSizes.gapL, MSizes.gapXS),
          child: Column(
            children: [
              // 프로필
              MProfileRow(),
              SizedBox(height: MSizes.gapM),

              // 팔로우 / 팔로잉 + 알림 버튼
              if (isFollowing) ...[
                Row(
                  children: [
                    Expanded(
                      child: MBtn(
                        icon: Icon(
                          CupertinoIcons.heart_fill,
                          color: MColors.textWhite,
                          size: MSizes.fontXL,
                        ),
                        text: '팔로잉',
                        onPressed: () {},
                        isFullWidth: false,
                        isSelected: !isFollowing,
                      ),
                    ),
                    SizedBox(width: MSizes.gapXS * 4),
                    Expanded(
                      child: MBtn(
                        icon: Icon(
                          isNotiOn ? CupertinoIcons.bell_fill : CupertinoIcons.bell_slash_fill,
                          color: MColors.textWhite,
                          size: MSizes.fontXL,
                        ),
                        text: '알림',
                        onPressed: () {},
                        isFullWidth: false,
                        isSelected: isNotiOn, // 켜짐이면 primaryStrong , 꺼짐이면 fillStrong
                      ),
                    ),
                  ],
                ),
              ] else ...[
                MBtn(
                  icon: Icon(
                    CupertinoIcons.heart,
                    color: MColors.textWhite,
                    size: MSizes.fontXL,
                  ),
                  text: '팔로우',
                  onPressed: () {},
                ),
              ],
            ],
          ),
        ),
        // 탭바
        SizedBox(
          height: 40,
          child: TabBar(
            tabs: const [
              Tab(text: '라이브'),
              Tab(text: '정보'),
            ],
            labelColor: MColors.textStrong,
            unselectedLabelColor: MColors.textAlternative,
            indicatorColor: MColors.primaryStrong,
            indicatorWeight: 1,
          ),
        ),
        // 탭바뷰
        Expanded(
          child: TabBarView(
            children: [
              // 라이브 영상 영역 (썸네일 + 제목 + 해시태그)
              MLive(),
              // 정보 영역
              MInfo(),
            ],
          ),
        ),
      ],
    );
  }
}
