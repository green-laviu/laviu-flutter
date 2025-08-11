import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/auth/login_page/widgets/login_body.dart';
import 'package:laviu_flutter/ui/pages/holder/main_holder.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBody(),
      floatingActionButton: MDevFloatingBtn(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainHolder()),
          );
        },
      ),
    );
  }
}
