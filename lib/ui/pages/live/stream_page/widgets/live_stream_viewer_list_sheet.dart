import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_viewer_info.dart';

class LiveStreamViewerListSheet extends StatelessWidget {
  const LiveStreamViewerListSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: MSizes.gapM,
              bottom: MediaQuery.of(context).padding.bottom + MSizes.gapM,
              left: MSizes.gapL,
              right: MSizes.gapL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Padding(
                  padding: EdgeInsets.only(top: MSizes.gapS, bottom: MSizes.gapL),
                  child: Text(
                    '라이브룸 멤버 (1000명)',
                    style: MText.heading3Bold(color: MColors.textNormal),
                  ),
                ),

                Text('스트리머', style: MText.heading4(color: MColors.textNormal)),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: MSizes.gapL, vertical: MSizes.gapM),
                      child: Row(
                        children: [
                          Text('스트리머닉네임 ', style: MText.heading4(color: MColors.primaryDanger)),
                          Text(
                            '(아이디)',
                            style: TextStyle(fontSize: MSizes.fontM, color: MColors.textNeutral),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MSizes.gapS),

                Text('시청자', style: MText.heading4(color: MColors.textNormal)),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      LiveStreamViewerInfo(nickname: '시청자닉네임1', username: '아이디1'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임2', username: '아이디2'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임3', username: '아이디3'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임4', username: '아이디4'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임5', username: '아이디5'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임6', username: '아이디6'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임7', username: '아이디7'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임8', username: '아이디8'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임9', username: '아이디9'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임10', username: '아이디10'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임11', username: '아이디11'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임13', username: '아이디13'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임14', username: '아이디14'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임15', username: '아이디15'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임16', username: '아이디16'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임17', username: '아이디17'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임18', username: '아이디18'),
                      LiveStreamViewerInfo(nickname: '시청자닉네임19', username: '아이디19'),
                      LiveStreamViewerInfo(nickname: '시청자 닉네임20', username: '아이디20'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
