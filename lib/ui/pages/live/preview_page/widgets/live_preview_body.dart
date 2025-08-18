import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/data/gvm/rtmp_publisher_gvm.dart';
import 'package:laviu_flutter/data/model/params/publisher_status.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/live_preview_fm.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_form.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_icon_bar.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/live_stream_vm.dart';
import 'package:laviu_flutter/ui/widgets/m_btn.dart';
import 'package:logger/logger.dart';

class LivePreviewBody extends ConsumerStatefulWidget {
  const LivePreviewBody({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  ConsumerState<LivePreviewBody> createState() => _LivePreviewBodyState();
}

class _LivePreviewBodyState extends ConsumerState<LivePreviewBody> {
  @override
  void initState() {
    super.initState();
    // 첫 프레임 이후에 init 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(rtmpPublisherProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    LiveStreamVM vm = ref.read(liveStreamProvider.notifier);
    LivePreviewModel previewModel = ref.watch(livePreviewProvider);

    RtmpPublisherGVM gvm = ref.read(rtmpPublisherProvider.notifier);
    RtmpPublisherModel pubModel = ref.watch(rtmpPublisherProvider);
    final status = pubModel.status;
    final isReady = status == PublisherStatus.previewing || status == PublisherStatus.live;
    final isError = status == PublisherStatus.error;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: isReady
              ? ApiVideoCameraPreview(
                  controller: gvm.controller!,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: MColors.black,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isError) ...[
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                      ],
                      Text(
                        isError ? (pubModel.lastError ?? '카메라 준비 실패') : '카메라 준비 중...',
                        style: TextStyle(color: MColors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),

        // 전체 오버레이 - 아이콘바 + 제목/해시태그 폼 + "생방송 시작하기" 버튼
        SafeArea(
          child: Column(
            children: [
              // 상단 아이콘바
              LivePreviewIconBar(),

              // 제목 + 해시태그
              LivePreviewForm(formKey: widget.formKey),

              Spacer(),

              // "생방송 시작하기" 버튼
              Padding(
                padding: EdgeInsets.fromLTRB(
                  MSizes.gapXXL,
                  0,
                  MSizes.gapXXL,
                  0,
                ),
                child: MBtn(
                  text: '생방송 시작하기',
                  onPressed: () {
                    if (widget.formKey.currentState!.validate()) {
                      // 검증 통과 → 제출
                      Logger().d("제목 검증 통과");
                      vm.start(previewModel.title, previewModel.hashtagList);
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

class _Overlay extends StatelessWidget {
  final String message;
  const _Overlay({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
