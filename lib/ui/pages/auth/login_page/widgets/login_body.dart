import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/auth/login_page/widgets/login_btn.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: MSizes.getScreenHeight(context) * 0.16),
          child: Column(
            children: [
              Text(
                'LAVIU',
                style: TextStyle(
                  color: MColors.textStrong,
                  fontSize: MSizes.fontHuge,
                ),
              ),
              Text(
                '라뷰를 이용하기 위해서는 로그인이 필요해요',
                style: TextStyle(
                  color: MColors.textNormal,
                  fontSize: MSizes.fontNormal,
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        LoginBtn(),
      ],
    );
  }
}
