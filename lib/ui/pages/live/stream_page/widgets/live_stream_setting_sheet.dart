import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_tag_dialog.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_viewer_list_sheet.dart';
import 'package:laviu_flutter/ui/widgets/m_fps_sheet.dart';
import 'package:laviu_flutter/ui/widgets/m_quality_sheet.dart';

class LiveStreamSettingSheet extends StatelessWidget {
  const LiveStreamSettingSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Padding(
              padding: EdgeInsets.symmetric(vertical: MSizes.gapS),
              child: Text(
                '방송 설정',
                style: MText.heading3Bold(color: MColors.textNormal),
              ),
            ),
            // 화질
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              leading: Icon(Icons.high_quality_outlined, color: MColors.textNormal),
              title: Text(
                '화질',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                '고화질 (720p)',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: MColors.backgroundNormal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                  ),
                  builder: (BuildContext context) {
                    return MQualitySheet();
                  },
                );
              },
            ),
            // 프레임 속도
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              leading: Icon(Icons.speed, color: MColors.textNormal),
              title: Text(
                '프레임 속도',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                '30fps',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: MColors.backgroundNormal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                  ),
                  builder: (BuildContext context) {
                    return MFpsSheet();
                  },
                );
              },
            ),
            // 시청자 목록
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              leading: Icon(Icons.people_alt_rounded, color: MColors.textNormal),
              title: Text(
                '시청자 목록',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  backgroundColor: MColors.backgroundNormal,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                  ),
                  builder: (context) {
                    return LiveStreamViewerListSheet();
                  },
                );
              },
            ),
            // 방송 태그
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              leading: Icon(Icons.tag_rounded, color: MColors.textNormal),
              title: Text(
                '방송 태그',
                style: TextStyle(color: MColors.textNormal, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false, //다이얼로그 밖 탭해도 닫히지 X
                  builder: (BuildContext context) {
                    return LiveStreamTagDialog();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
