import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/user/detail_page/user_detail_vm.dart';
import 'package:laviu_flutter/ui/widgets/m_btn.dart';
import 'package:laviu_flutter/ui/widgets/m_live.dart';
import 'package:laviu_flutter/ui/widgets/m_profile_row.dart';
import 'package:laviu_flutter/ui/widgets/m_user_info.dart';

class UserDetailBody extends ConsumerWidget {
  int userId;

  UserDetailBody(this.userId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserDetailModel? model = ref.watch(userDetailProvider(userId));

    final bool isFollowing = false;
    final bool isNotiOn = false; // 알림 꺼짐이면 false

    if (model == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          // 탭바 위 헤더 (프로필 + 버튼)
          Padding(
            padding: EdgeInsets.fromLTRB(
              MSizes.gapL,
              MSizes.gapM,
              MSizes.gapL,
              MSizes.gapXS,
            ),
            child: Column(
              children: [
                // 프로필
                MProfileRow(model.user),
                SizedBox(height: MSizes.gapM),

                // 팔로우 / 팔로잉 + 알림 버튼
                if (model.isFollowing) ...[
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
                          isSelected: !(model.isFollowing),
                        ),
                      ),
                      SizedBox(width: MSizes.gapXS * 4),
                      Expanded(
                        child: MBtn(
                          icon: Icon(
                            model.isNotified
                                ? CupertinoIcons.bell_fill
                                : CupertinoIcons.bell_slash_fill,
                            color: MColors.textWhite,
                            size: MSizes.fontXL,
                          ),
                          text: '알림',
                          onPressed: () {},
                          isFullWidth: false,
                          isSelected: model
                              .isNotified, // 켜짐이면 primaryStrong , 꺼짐이면 fillStrong
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
                (model.liveStream == null)
                    ? Center(
                        child: Text(
                          "진행중인 라이브가 없습니다",
                          style: MText.label2Bold(
                            color: MColors.textNormal,
                          ),
                        ),
                      )
                    : MLive(model.liveStream!),
                // 정보 영역
                MUserInfo(model.user),
              ],
            ),
          ),
        ],
      );
    }
  }
}
