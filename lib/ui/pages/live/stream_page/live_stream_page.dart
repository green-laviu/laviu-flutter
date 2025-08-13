import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_icon_bar.dart';
import 'package:laviu_flutter/ui/widgets/m_tag_chip.dart';
import 'package:logger/logger.dart';

class LiveStreamPage extends StatefulWidget {
  const LiveStreamPage({super.key});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  final _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: 카메라 프리뷰 자리
          Container(color: MColors.primaryBackground),

          // 전체 오버레이 - 아이콘바 + 제목/해시태그 + 채팅 리스트 + 채팅 입력 필드
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 아이콘바
                LiveStreamIconBar(),

                // 제목 + 해시태그
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: MSizes.gapXXL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        '제목',
                        style: TextStyle(
                          fontSize: MSizes.fontXXL,
                          fontWeight: FontWeight.w700,
                          color: MColors.textWhite,
                        ),
                      ),
                      SizedBox(height: MSizes.gapS),
                      // 태그
                      Row(
                        children: [
                          MTagChip(label: '#소통방송'),
                          SizedBox(width: MSizes.gapS),
                          MTagChip(label: '#해시'),
                          SizedBox(width: MSizes.gapS),
                          MTagChip(label: '#태그'),
                        ],
                      ),
                    ],
                  ),
                ),

                // 채팅 리스트
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: MSizes.gapXXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 300,
                          child: ListView(
                            reverse: true,
                            children: [
                              // 채팅 : 서버에서 최근 메시지 → 오래된 메시지 순으로
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
                          ),
                        ),
                        SizedBox(height: MSizes.gapM),
                        // 채팅 입력 필드
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _msgCtrl,
                                cursorColor: MColors.white,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: "메시지를 입력하세요",
                                  hintStyle: MText.inputMedium(color: MColors.textWhite),
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
                                onSubmitted: (value) {
                                  _msgCtrl.clear();
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Logger().d("전송 버튼 클릭");
                              },

                              child: Padding(
                                padding: EdgeInsets.only(left: MSizes.gapM),
                                child: Icon(Icons.send, color: MColors.white, size: MSizes.iconM),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: MDevFloatingBtn(
      //   icon: Icons.arrow_back,
      //   onPressed: () => Navigator.pop(context),
      // ),
    );
  }
}

class LiveStreamChatMsg extends StatelessWidget {
  final bool isStreamer;
  final String nickName;
  final String msg;

  const LiveStreamChatMsg({
    super.key,
    this.isStreamer = false,
    required this.nickName,
    required this.msg,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          isStreamer
              ? WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Icon(
                    CupertinoIcons.mic_solid,
                    color: MColors.primaryDanger,
                    size: MSizes.fontM,
                  ),
                )
              : WidgetSpan(child: SizedBox.shrink()),
          TextSpan(
            text: '$nickName     ',
            style: TextStyle(
              color: isStreamer ? MColors.primaryDanger : MColors.primaryStrong,
              fontSize: MSizes.fontM,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: msg,
            style: TextStyle(
              color: MColors.white,
              fontSize: MSizes.fontM,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
