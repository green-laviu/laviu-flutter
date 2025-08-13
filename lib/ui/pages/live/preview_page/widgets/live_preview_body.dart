import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_form.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_icon_bar.dart';
import 'package:laviu_flutter/ui/widgets/m_btn.dart';
import 'package:logger/logger.dart';

class LivePreviewBody extends StatelessWidget {
  const LivePreviewBody({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // TODO: 카메라 프리뷰 자리
        Container(color: MColors.primaryBackground),

        // 전체 오버레이 - 아이콘바 + 제목/해시태그 폼 + "생방송 시작하기" 버튼
        SafeArea(
          child: Column(
            children: [
              // 상단 아이콘바
              LivePreviewIconBar(),

              // 제목 + 해시태그
              LivePreviewForm(formKey: formKey),

              Spacer(),

              // "생방송 시작하기" 버튼
              Padding(
                padding: EdgeInsets.fromLTRB(MSizes.gapXXL, 0, MSizes.gapXXL, 0),
                child: MBtn(
                  text: '생방송 시작하기',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // 검증 통과 → 제출
                      Logger().d("제목 검증 통과");
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
