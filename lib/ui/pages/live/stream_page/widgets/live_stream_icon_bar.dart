import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_setting_sheet.dart';
import 'package:laviu_flutter/ui/widgets/m_dialog.dart';

class LiveStreamIconBar extends StatelessWidget {
  const LiveStreamIconBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                '12:12:30',
                style: TextStyle(color: MColors.white, fontWeight: FontWeight.w900, fontSize: MSizes.fontNormal),
              ),
            ),
          ),
          Row(
            children: [
              // 마이크 설정 버튼
              IconButton(
                icon: Icon(Icons.mic, color: MColors.white),
                onPressed: () {},
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 가로/세로 화면 전환 버튼
              IconButton(
                icon: Icon(Icons.screen_rotation, color: MColors.white),
                onPressed: () {},
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 카메라 전/후면 전환 버튼
              IconButton(
                icon: Icon(Icons.flip_camera_ios, color: MColors.white),
                onPressed: () {},
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
                          message: '지금 방송을 종료하시면 나중에 저장안됩니다 책임안져용',
                          primaryText: '확인',
                          onPrimaryTap: () {
                            Navigator.pop(context);
                          },
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
