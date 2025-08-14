import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_viewer_manage_sheet.dart';

class LiveStreamViewerInfo extends StatelessWidget {
  final String nickname;
  final String username;

  const LiveStreamViewerInfo({
    super.key,
    required this.nickname,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapL),
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
      title: Row(
        children: [
          Text(
            '$nickname ',
            style: TextStyle(
              fontSize: MSizes.fontM,
              color: MColors.primaryStrong,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '($username)',
            style: TextStyle(fontSize: MSizes.fontM, color: MColors.textNeutral),
          ),
        ],
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
            return LiveStreamViewerManageSheet(isKicked: false, nickname: nickname, username: username);
          },
        );
      },
    );
  }
}
