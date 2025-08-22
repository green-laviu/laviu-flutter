import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_msg.dart';
import 'package:laviu_flutter/ui/pages/live/streaming_page/chat_list_vm.dart';

class LiveStreamChatList extends ConsumerWidget {
  const LiveStreamChatList({
    super.key,
    required ScrollController scrollCtrl,
    required this.streamKey,
  }) : _scrollCtrl = scrollCtrl;

  final ScrollController _scrollCtrl;
  final String streamKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ChatListModel? model = ref.watch(chatListProvider(streamKey));

    // ref.listen :상태 변화가 생길 때 특정 동작을 실행 (prev: 이전 상태, next: 바뀐 후 상태)
    ref.listen<ChatListModel?>(chatListProvider(streamKey), (prev, next) {
      if (next == null) return;

      final prevLen = prev?.chatMessageList.length ?? 0;
      final nextLen = next.chatMessageList.length;

      final hasNewMessage = nextLen > prevLen;
      if (!hasNewMessage) return;

      if (_isNearBottom(_scrollCtrl, threshold: 100)) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          // 화면 그리기가 다 끝난 뒤에 실행
          if (!_scrollCtrl.hasClients) return;
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: MSizes.animDurationFast,
            curve: Curves.easeOut,
          );
        });
      }
    });

    if (model == null) {
      return const SizedBox.shrink();
    } else {
      return ListView.builder(
        controller: _scrollCtrl,
        itemCount: model.chatMessageList.length,
        itemBuilder: (context, index) {
          final m = model.chatMessageList[index];
          return LiveStreamChatMsg(
            isStreamer: m.isStreamer,
            nickName: m.authorNickname,
            msg: m.content,
          );
        },
      );
    }
  }
}

/// 바닥에서 threshold 픽셀 이내면 true
bool _isNearBottom(ScrollController ctrl, {double threshold = 80}) {
  if (!ctrl.hasClients) return false; // ctrl가 위젯과 연결되었는지
  final position = ctrl.position; // position : 현재 스크롤 상태를 알려줌
  final distance =
      position.maxScrollExtent -
      position.pixels; // 바닥까지 남은 거리 계산 : 스크롤 가능한 최대 길이 (맨 아래 지점) - 지금 스크롤이 어디까지 내려와 있는지 (현재 위치)
  return distance <= threshold; // threshold : 임계값(여유 거리)
}
