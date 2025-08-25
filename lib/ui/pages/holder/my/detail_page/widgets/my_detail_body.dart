import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/my_detail_vm.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/my_update_page.dart';
import 'package:laviu_flutter/ui/widgets/m_btn.dart';
import 'package:laviu_flutter/ui/widgets/m_live.dart';
import 'package:laviu_flutter/ui/widgets/m_profile_row.dart';
import 'package:laviu_flutter/ui/widgets/m_user_info.dart';

class MyDetailBody extends ConsumerWidget {
  const MyDetailBody({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MyDetailModel? model = ref.watch(myDetailProvider);

    if (model == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          // 탭바 위 헤더 (프로필 + 채널 관리 버튼)
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
                // 채널 관리 (유저 정보 수정) 버튼
                MBtn(
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
