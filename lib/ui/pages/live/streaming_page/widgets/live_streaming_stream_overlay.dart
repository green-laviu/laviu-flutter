import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/live_stream_vm.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_input_bar.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_list.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_icon_bar.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_info.dart';

class LiveStreamingStreamOverlay extends ConsumerWidget {
  const LiveStreamingStreamOverlay({
    super.key,
    required ScrollController scrollCtrl,
    required TextEditingController msgCtrl,
    required this.onStop,
    required this.onToggleMute,
    required this.onSwitchCamera,
    required this.isMuted,
    required this.isFrontCamera,
  }) : _scrollCtrl = scrollCtrl,
       _msgCtrl = msgCtrl;

  final ScrollController _scrollCtrl;
  final TextEditingController _msgCtrl;
  final VoidCallback onStop;
  final VoidCallback? onToggleMute;
  final VoidCallback? onSwitchCamera;
  final bool isMuted;
  final bool isFrontCamera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(liveStreamProvider);

    if (model == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 아이콘바
          LiveStreamIconBar(
            onStop: onStop,
            onToggleMute: onToggleMute,
            onSwitchCamera: onSwitchCamera,
            isMuted: isMuted,
            isFrontCamera: isFrontCamera,
            streamKey: model.liveStream.streamKey,
          ),

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
                    child: LiveStreamChatList(
                      scrollCtrl: _scrollCtrl,
                      streamKey: model.liveStream.streamKey,
                    ),
                  ),
                  SizedBox(height: MSizes.gapM),
                  // 채팅 입력 바
                  LiveStreamChatInputBar(
                    msgCtrl: _msgCtrl,
                    streamKey: model.liveStream.streamKey,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}
