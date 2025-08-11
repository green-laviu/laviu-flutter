import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/my_update_page.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class MyDetailPage extends StatelessWidget {
  const MyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("나의 상세 페이지"),
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
