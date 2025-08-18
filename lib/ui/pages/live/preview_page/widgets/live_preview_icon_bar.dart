import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/data/gvm/rtmp_publisher_gvm.dart';
import 'package:laviu_flutter/data/model/params/publisher_status.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_setting_sheet.dart';

class LivePreviewIconBar extends ConsumerWidget {
  const LivePreviewIconBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    RtmpPublisherGVM gvm = ref.read(rtmpPublisherProvider.notifier);
    RtmpPublisherModel pubModel = ref.watch(rtmpPublisherProvider);
    final isReady = (pubModel.status == PublisherStatus.previewing || pubModel.status == PublisherStatus.live);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MSizes.gapM, vertical: MSizes.gapM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 나가기 버튼
          IconButton(
            icon: Icon(Icons.close, color: MColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              // 마이크 설정 버튼
              IconButton(
                tooltip: pubModel.isMuted ? '마이크 켜기' : '마이크 끄기',
                icon: Icon(pubModel.isMuted ? Icons.mic_off : Icons.mic, color: MColors.white),
                onPressed: isReady ? () => gvm.toggleMute() : null, // 준비 안되면 비활성화
              ),
              // 가로/세로 화면 전환 버튼
              IconButton(
                icon: Icon(Icons.screen_rotation, color: MColors.white),
                onPressed: () {}, // TODO : 가로/세로 화면 전환 추후 처리
              ),
              // 카메라 전/후면 전환 버튼
              IconButton(
                tooltip: pubModel.isFrontCamera ? '후면으로 전환' : '전면으로 전환',
                icon: Icon(Icons.flip_camera_ios, color: MColors.white),
                onPressed: isReady ? () => gvm.switchCamera() : null, // 준비 안되면 비활성화
              ),
              // 방송 설정 버튼
              IconButton(
                icon: Icon(Icons.settings, color: MColors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: false,
                    backgroundColor: MColors.backgroundNormal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                    ),
                    builder: (BuildContext sheetContext) {
                      return LivePreviewSettingSheet();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
