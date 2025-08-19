import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_setting_sheet.dart';

class LivePreviewIconBar extends ConsumerWidget {
  const LivePreviewIconBar({
    super.key,
    required this.onClose,
    this.onToggleMute,
    this.onSwitchCamera,
    this.isMuted = false,
    this.isFrontCamera = true,
  });

  final VoidCallback onClose;
  final VoidCallback? onToggleMute; // null이면 자동 비활성화
  final VoidCallback? onSwitchCamera; // null이면 자동 비활성화
  final bool isMuted;
  final bool isFrontCamera;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MSizes.gapM, vertical: MSizes.gapM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 나가기 버튼
          IconButton(
            icon: Icon(Icons.close, color: MColors.white),
            onPressed: onClose,
          ),
          Row(
            children: [
              // 마이크 설정 버튼
              IconButton(
                tooltip: isMuted ? '마이크 켜기' : '마이크 끄기',
                icon: Icon(isMuted ? Icons.mic_off : Icons.mic, color: MColors.white),
                onPressed: onToggleMute,
              ),
              // 가로/세로 화면 전환 버튼
              IconButton(
                icon: Icon(Icons.screen_rotation, color: MColors.white),
                onPressed: () {}, // TODO : 가로/세로 화면 전환 추후 처리
              ),
              // 카메라 전/후면 전환 버튼
              IconButton(
                tooltip: isFrontCamera ? '후면으로 전환' : '전면으로 전환',
                icon: Icon(Icons.flip_camera_ios, color: MColors.white),
                onPressed: onSwitchCamera,
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
