import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/user/detail_page/user_detail_page.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("홈 페이지"),
      ),
      floatingActionButton: MDevFloatingBtn(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => UserDetailPage()),
          );
        },
        icon: Icons.person,
      ),
    );
  }
}
