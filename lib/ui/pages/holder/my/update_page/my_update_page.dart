import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/widgets/my_update_body.dart';

class MyUpdatePage extends StatelessWidget {
  const MyUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: _appbar(),
      body: MyUpdateBody(),
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: Text(
        '채널 관리',
        style: MText.heading1(color: MColors.textNormal),
      ),
    );
  }
}
