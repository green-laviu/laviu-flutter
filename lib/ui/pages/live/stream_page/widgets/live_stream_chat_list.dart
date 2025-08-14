import 'package:flutter/material.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_msg.dart';

class LiveStreamChatList extends StatelessWidget {
  const LiveStreamChatList({
    super.key,
    required ScrollController scrollCtrl,
  }) : _scrollCtrl = scrollCtrl;

  final ScrollController _scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollCtrl,
      reverse: true, // 최신 메시지가 아래로
      children: [
        // 채팅
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(isStreamer: true, nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
        LiveStreamChatMsg(nickName: '시청자1', msg: '채팅내용~~~'),
      ],
    );
  }
}
