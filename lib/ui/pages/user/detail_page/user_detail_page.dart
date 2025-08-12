import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/user/detail_page/widgets/user_detail_body.dart';

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 라이브, 정보
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(),
        body: UserDetailBody(),
      ),
    );
  }
}
