import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/live_preview_fm.dart';

class LivePreviewTitleFormField extends ConsumerWidget {
  const LivePreviewTitleFormField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LivePreviewFM fm = ref.read(livePreviewProvider.notifier);

    return TextFormField(
      onChanged: (value) {
        fm.title(value);
      },
      validator: (value) =>
          (value == null || value.isEmpty) ? '제목을 입력하세요' : null,
      cursorColor: MColors.white,
      decoration: InputDecoration(
        hintText: '제목',
        hintStyle: TextStyle(
          fontSize: MSizes.fontXXL,
          fontWeight: FontWeight.w700,
          color: MColors.textWhite,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        errorStyle: MText.label3(color: MColors.error),
      ),
      style: TextStyle(
        fontSize: MSizes.fontXXL,
        fontWeight: FontWeight.w700,
        color: MColors.textWhite,
      ),
    );
  }
}
