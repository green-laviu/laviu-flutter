import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_form.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_icon_bar.dart';
import 'package:laviu_flutter/ui/widgets/m_btn.dart';

class LiveStreamingPreviewOverlay extends ConsumerWidget {
  const LiveStreamingPreviewOverlay({
    super.key,
    required this.formKey,
    required this.onStart,
    required this.onClose,
    required this.onToggleMute,
    required this.onSwitchCamera,
    required this.isMuted,
    required this.isFrontCamera,
  });

  final GlobalKey<FormState> formKey;
  final Future<void> Function() onStart;
  final VoidCallback onClose;
  final VoidCallback? onToggleMute;
  final VoidCallback? onSwitchCamera;
  final bool isMuted;
  final bool isFrontCamera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 상단 아이콘바
        LivePreviewIconBar(
          onClose: onClose,
          onToggleMute: onToggleMute,
          onSwitchCamera: onSwitchCamera,
          isMuted: isMuted,
          isFrontCamera: isFrontCamera,
        ),

        // 제목 + 해시태그
        LivePreviewForm(formKey: formKey),

        Spacer(),

        // "생방송 시작하기" 버튼
        Padding(
          padding: EdgeInsets.symmetric(horizontal: MSizes.gapXXL),
          child: MBtn(
            text: '생방송 시작하기',
            onPressed: () async => await onStart(),
          ),
        ),
      ],
    );
  }
}
