import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/auth/login_page/login_page.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';
import 'package:logger/logger.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      Logger().d("1. dotenv 시작");
      await dotenv.load(fileName: ".env");

      // Logger().d("2. FCM 토큰 시작");
      // await MFcm.initFcmToken();

      // Logger().d("3. FCM initial message");
      // FirebaseMessaging.instance.getInitialMessage();

      Logger().d("splash: 초기화 완료");

      setState(() {
        _isInitialized = true;
      });

      Future.delayed(MSizes.animDurationFast, () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      });
    } catch (e) {
      Logger().e("splash: 초기화 에러: $e");
    }
  }

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
