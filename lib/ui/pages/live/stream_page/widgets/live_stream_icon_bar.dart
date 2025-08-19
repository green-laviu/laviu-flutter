import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_setting_sheet.dart';
import 'package:laviu_flutter/ui/widgets/m_dialog.dart';

class LiveStreamIconBar extends ConsumerWidget {
  const LiveStreamIconBar({
    super.key,
    required this.onStop,
    this.onToggleMute,
    this.onSwitchCamera,
    this.isMuted = false,
    this.isFrontCamera = true,
  });

  final VoidCallback onStop;
  final VoidCallback? onToggleMute; // null이면 자동 비활성화
  final VoidCallback? onSwitchCamera; // null이면 자동 비활성화
  final bool isMuted;
  final bool isFrontCamera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final timeText = pubModel.startedAt != null ? DateFormat.Hms().format(pubModel.startedAt!) : "--:--:--";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MSizes.gapM, vertical: MSizes.gapM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 라이브 진행 시간
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MSizes.gapM, vertical: MSizes.gapXS),
              decoration: BoxDecoration(
                color: MColors.primaryAccent.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(MSizes.radiusCircle),
              ),
              child: Text(
                '--:--:--',
                style: TextStyle(color: MColors.white, fontWeight: FontWeight.w900, fontSize: MSizes.fontNormal),
              ),
            ),
          ),
          Row(
            children: [
              // 마이크 설정 버튼
              IconButton(
                tooltip: isMuted ? '마이크 켜기' : '마이크 끄기',
                icon: Icon(isMuted ? Icons.mic_off : Icons.mic, color: MColors.white),
                onPressed: onToggleMute,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 가로/세로 화면 전환 버튼
              IconButton(
                icon: Icon(Icons.screen_rotation, color: MColors.white),
                onPressed: () {}, // TODO : 가로/세로 화면 전환 추후 처리
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 카메라 전/후면 전환 버튼
              IconButton(
                tooltip: isFrontCamera ? '후면으로 전환' : '전면으로 전환',
                icon: Icon(Icons.flip_camera_ios, color: MColors.white),
                onPressed: onSwitchCamera,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
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
                      return LiveStreamSettingSheet();
                    },
                  );
                },
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 종료 버튼
              Padding(
                padding: EdgeInsets.only(left: MSizes.gapS, right: 15),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(MColors.grey),
                    minimumSize: WidgetStatePropertyAll(Size.zero),
                    visualDensity: VisualDensity(horizontal: 0, vertical: -1.3),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(MSizes.radiusS)),
                    ),
                  ),
                  child: Text(
                    '종료',
                    style: TextStyle(color: MColors.white, fontWeight: FontWeight.w900, fontSize: MSizes.fontNormal),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return MDialog(
                          title: '방송을 종료하시겠어요?',
                          message: '지금 방송을 종료하면 저장되지 않아요. 정말 종료하시겠어요?',
                          primaryText: '확인',
                          onPrimaryTap: onStop,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
