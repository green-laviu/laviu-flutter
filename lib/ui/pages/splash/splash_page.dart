import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/auth/login_page/login_page.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("스플래시 페이지"),
      ),
      floatingActionButton: MDevFloatingBtn(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        },
      ),
    );
  }
}
