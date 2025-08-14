import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/widgets/live_preview_setting_sheet.dart';

class LivePreviewIconBar extends StatelessWidget {
  const LivePreviewIconBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                icon: Icon(Icons.mic, color: MColors.white),
                onPressed: () {},
              ),
              // 가로/세로 화면 전환 버튼
              IconButton(
                icon: Icon(Icons.screen_rotation, color: MColors.white),
                onPressed: () {},
              ),
              // 카메라 전/후면 전환 버튼
              IconButton(
                icon: Icon(Icons.flip_camera_ios, color: MColors.white),
                onPressed: () {},
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
