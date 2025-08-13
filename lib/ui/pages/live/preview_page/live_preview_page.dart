import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_body.dart';

class LivePreviewPage extends StatelessWidget {
  const LivePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus(); // 빈영역 터치 -> 키보드 내려감
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: LivePreviewBody(formKey: formKey),
      ),
    );
  }
}
