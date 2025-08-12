import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/widgets/my_detail_body.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/my_update_page.dart';
import 'package:laviu_flutter/ui/pages/user/detail_page/user_detail_page.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class MyDetailPage extends StatelessWidget {
  const MyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 라이브, 정보
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(),
        body: MyDetailBody(),
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
