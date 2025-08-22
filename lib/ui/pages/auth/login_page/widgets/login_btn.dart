import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_icons.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/gvm/session_gvm.dart';
import 'package:logger/logger.dart';

class LoginBtn extends ConsumerWidget {
  const LoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SessionGVM gvm = ref.read(sessionProvider.notifier);

    return Padding(
      padding: EdgeInsets.all(MSizes.gapL),
      child: SizedBox(
        height: MSizes.heightButton,
        child: ElevatedButton(
          onPressed: () async {
            // 1. 네이버 토큰 받아오기
            final accessToken = await _getNaverToken();
            // 2. spring 서버에 전달 및 로그인
            if (accessToken != null) {
              await gvm.oauthLogin(accessToken);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF03C759),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MSizes.radiusM),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  '네이버 로그인',
                  style: MText.button4Medium(color: MColors.white),
                ),
              ),
              Positioned(
                left: MSizes.gapL,
                child: MIcons.loginNaverLogo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getNaverToken() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      if (result.status == NaverLoginStatus.loggedIn) {
        final naverToken = await FlutterNaverLogin.getCurrentAccessToken();
        if (naverToken.isValid()) {
          return naverToken.accessToken;
        } else {
          Logger().d('토큰이 유효하지 않음');
        }
      } else {
        Logger().d('네이버 로그인 실패: ${result.errorMessage}');
      }
    } catch (error) {
      Logger().d('로그인 중 오류 발생: $error');
    }
    return null;
  }
}
