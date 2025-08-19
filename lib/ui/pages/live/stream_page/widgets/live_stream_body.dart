import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/data/gvm/rtmp_publisher_gvm.dart';
import 'package:laviu_flutter/data/model/params/publisher_status.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_input_bar.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_list.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_info.dart';

class LiveStreamBody extends ConsumerWidget {
  const LiveStreamBody({
    super.key,
    required ScrollController scrollCtrl,
    required TextEditingController msgCtrl,
  }) : _scrollCtrl = scrollCtrl,
       _msgCtrl = msgCtrl;

  final ScrollController _scrollCtrl;
  final TextEditingController _msgCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    RtmpPublisherGVM gvm = ref.read(rtmpPublisherProvider.notifier);
    RtmpPublisherModel pubModel = ref.watch(rtmpPublisherProvider);

    final status = pubModel.status;
    final isReady = status == PublisherStatus.previewing || status == PublisherStatus.live;
    final isError = status == PublisherStatus.error;

    final showPreview =
        pubModel.status == PublisherStatus.previewing ||
        pubModel.status == PublisherStatus.connecting ||
        pubModel.status == PublisherStatus.live;

    final hasTex = gvm.controller?.textureId != null && gvm.controller!.textureId! > 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 카메라 프리뷰 자리
        Positioned.fill(
          child: (showPreview && hasTex)
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
                        style: const TextStyle(color: MColors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),

        // 전체 오버레이 - 아이콘바 + 제목/해시태그 + 채팅 영역 (채팅 리스트 + 채팅 입력 바)
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 아이콘바
              //LiveStreamIconBar(),

              // 제목/해시태그
              LiveStreamInfo(),

              // 채팅 영역 (채팅 리스트 + 채팅 입력 바)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: MSizes.gapXXL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 채팅 리스트
                      SizedBox(
                        height: 300,
                        child: LiveStreamChatList(scrollCtrl: _scrollCtrl),
                      ),
                      SizedBox(height: MSizes.gapM),
                      // 채팅 입력 바
                      LiveStreamChatInputBar(msgCtrl: _msgCtrl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
