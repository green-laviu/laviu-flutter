import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/auth/login_page/login_page.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAC3C4),
      body: Center(
        child: Image.asset(
          'assets/images/splash.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
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
