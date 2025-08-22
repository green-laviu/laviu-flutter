import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/_core/utils/m_util.dart';
import 'package:laviu_flutter/data/gvm/session_gvm.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_viewer_info.dart';
import 'package:laviu_flutter/ui/pages/live/streaming_page/participant_list_vm.dart';

class LiveStreamViewerListSheet extends ConsumerWidget {
  const LiveStreamViewerListSheet({
    super.key,
    required this.streamKey,
  });

  final String streamKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ParticipantListModel? model = ref.watch(participantListProvider(streamKey));
    SessionModel sessionModel = ref.read(sessionProvider);

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
                    '시청자 목록',
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
                          Text('${sessionModel.user!.nickname}', style: MText.heading4(color: MColors.primaryDanger)),
                          Text(
                            extractEmailId('${sessionModel.user!.email}'),
                            style: TextStyle(fontSize: MSizes.fontM, color: MColors.textNeutral),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MSizes.gapS),

                Text('시청자', style: MText.heading4(color: MColors.textNormal)),
                if (model == null) ...[
                  const SizedBox.shrink(),
                ] else ...[
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: model.participantList.length,
                      itemBuilder: (context, index) {
                        final m = model.participantList[index];
                        return LiveStreamViewerInfo(
                          nickname: m.nickname,
                          username: m.emailId,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
