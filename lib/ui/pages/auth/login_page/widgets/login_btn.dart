import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_icons.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class LoginBtn extends StatelessWidget {
  const LoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MSizes.gapL),
      child: SizedBox(
        height: MSizes.heightButton,
        child: ElevatedButton(
          onPressed: () {},
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
}
