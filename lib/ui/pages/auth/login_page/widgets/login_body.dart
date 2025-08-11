import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/auth/login_page/widgets/login_btn.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/onboarding.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 105,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "지금 이 순간을 나누고 싶다면\n라뷰에서 라이브로 시작하세요",
                        style: MText.heading2(color: MColors.textStrong),
                      ),
                      SizedBox(height: MSizes.gapM),
                      Text(
                        '라뷰를 이용하기 위해서는 로그인이 필요해요',
                        style: TextStyle(color: MColors.textStrong, fontSize: MSizes.fontNormal),
                      ),
                    ],
                  ),
                ),
              ),
              LoginBtn(),
            ],
          ),
        ],
      ),
    );
  }
}
