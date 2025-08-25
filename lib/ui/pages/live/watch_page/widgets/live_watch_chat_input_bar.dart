import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/live/streaming_page/chat_list_vm.dart';
import 'package:logger/logger.dart';

class LiveWatchChatInputBar extends ConsumerWidget {
  const LiveWatchChatInputBar({
    super.key,
    required TextEditingController msgCtrl,
    required ScrollController scrollCtrl,
    required this.streamKey,
    required this.streamId,
  }) : _msgCtrl = msgCtrl,
       _scrollCtrl = scrollCtrl;

  final TextEditingController _msgCtrl;
  final ScrollController _scrollCtrl;
  final String streamKey;
  final int streamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(chatListProvider((streamKey, streamId)).notifier);

    void sendChat() {
      final text = _msgCtrl.text.trim();
      if (text.isEmpty) return;

      vm.sendChat(text);

      _msgCtrl.clear();

      FocusScope.of(context).unfocus(); // 키보드 내리기

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollCtrl.hasClients) return;
        final offset = _scrollCtrl.position.maxScrollExtent;
        _scrollCtrl.animateTo(
          offset,
          duration: MSizes.animDurationFast,
          curve: Curves.easeOut,
        );
      });

      Logger().d("채팅 전송: $text");
    }

    return Row(
      children: [
        // 입력 필드
        Expanded(
          child: TextField(
            controller: _msgCtrl,
            style: MText.inputMedium(color: MColors.textNormal),
            cursorColor: MColors.white,
            decoration: InputDecoration(
              isDense: true,
              hintText: "메시지를 입력하세요",
              hintStyle: MText.inputMedium(color: MColors.textNeutral),
              contentPadding: EdgeInsets.symmetric(
                horizontal: MSizes.gapM,
                vertical: MSizes.gapM,
              ), // 내부 여백
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MSizes.radiusXL),
                borderSide: BorderSide(color: MColors.primaryStrong, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MSizes.radiusXL),
                borderSide: BorderSide(color: MColors.primaryStrong, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MSizes.radiusXL),
                borderSide: BorderSide(color: MColors.primaryStrong, width: 2),
              ),
            ),
            onSubmitted: (_) => sendChat(),
          ),
        ),
        // 전송 버튼
        GestureDetector(
          onTap: sendChat,
          child: Padding(
            padding: EdgeInsets.only(left: MSizes.gapL),
            child: Icon(Icons.send, color: MColors.textNormal, size: MSizes.iconM),
          ),
        ),
      ],
    );
  }
}
