import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/holder/main_holder.dart';
import 'package:laviu_flutter/ui/widgets/m_dev_floating_btn.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("로그인 페이지"),
      ),
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
