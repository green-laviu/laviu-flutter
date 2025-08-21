import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    if (model == null) {
      return Container();
    } else {
      return ListView.builder(
        controller: _scrollCtrl,
        reverse: true, // 최신 메시지가 아래로
        itemCount: model.chatMessageList.length,
        itemBuilder: (context, index) {
          final m = model.chatMessageList[index];
          return LiveStreamChatMsg(
            isStreamer: m.streamer,
            nickName: m.authorNickname,
            msg: m.content,
          );
        },
      );
    }
  }
}
