import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/my_update_page.dart';
import 'package:laviu_flutter/ui/pages/user/detail_page/user_detail_page.dart';
import 'package:laviu_flutter/ui/widgets/m_btn.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';
import 'package:laviu_flutter/ui/widgets/m_info.dart';
import 'package:laviu_flutter/ui/widgets/m_live.dart';
import 'package:laviu_flutter/ui/widgets/m_profile_row.dart';

class MyDetailPage extends StatelessWidget {
  const MyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 라이브, 정보
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            // 탭바 위 헤더 (프로필 + 채널 관리 버튼)
            Padding(
              padding: EdgeInsets.fromLTRB(MSizes.gapL, MSizes.gapM, MSizes.gapL, MSizes.gapXS),
              child: Column(
                children: [
                  // 프로필
                  MProfileRow(),
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
                  MLive(),
                  // 정보 영역
                  MInfo(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            MDevFloatingBtn(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => MyUpdatePage()),
                );
              },
              icon: Icons.person,
            ),
            SizedBox(width: 10),
            MDevFloatingBtn(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => UserDetailPage()),
                );
              },
              icon: Icons.people,
            ),
          ],
        ),
      ),
    );
  }
}
