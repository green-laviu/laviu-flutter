import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_hashtag_form_field.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_title_form_field.dart';

class LivePreviewForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const LivePreviewForm({
    super.key,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MSizes.gapXXL),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 필드
            LivePreviewTitleFormField(),

            // 해시태그 필드
            LivePreviewHashtagFormField(),
          ],
        ),
      ),
    );
  }
}
