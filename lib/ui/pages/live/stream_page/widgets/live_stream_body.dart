import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_input_bar.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_list.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_icon_bar.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_info.dart';

class LiveStreamBody extends StatelessWidget {
  const LiveStreamBody({
    super.key,
    required ScrollController scrollCtrl,
    required TextEditingController msgCtrl,
  }) : _scrollCtrl = scrollCtrl,
       _msgCtrl = msgCtrl;

  final ScrollController _scrollCtrl;
  final TextEditingController _msgCtrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // TODO: 카메라 프리뷰 자리
        Container(color: MColors.primaryBackground),

        // 전체 오버레이 - 아이콘바 + 제목/해시태그 + 채팅 영역 (채팅 리스트 + 채팅 입력 바)
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 아이콘바
              LiveStreamIconBar(),

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
