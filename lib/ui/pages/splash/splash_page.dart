import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/auth/login_page/login_page.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.primaryBackground,
      body: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 43.0,
            fontWeight: FontWeight.bold,
          ),
          child: AnimatedTextKit(
            repeatForever: true,
            pause: MSizes.animDurationFast,
            animatedTexts: [
              RotateAnimatedText('LAVIU'),
              RotateAnimatedText('LIVE VIEW'),
            ],
          ),
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
