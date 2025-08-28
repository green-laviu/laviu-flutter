import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class MQualitySheet extends StatefulWidget {
  const MQualitySheet({
    super.key,
  });

  @override
  State<MQualitySheet> createState() => _MQualitySheetState();
}

class _MQualitySheetState extends State<MQualitySheet> {
  String _selectedQuality = '1080p';

  void _onSelectQuality(String quality) {
    setState(() {
      _selectedQuality = quality;
    });
  }

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
                '화질',
                style: MText.heading3Bold(color: MColors.textNormal),
              ),
            ),
            // 고화질 (1080p)
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              title: Text(
                '고화질 (1080p)',
                style: TextStyle(
                  color: MColors.textNormal,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: _selectedQuality == '1080p' ? Icon(Icons.check, color: MColors.textNormal) : null,
              onTap: () => _onSelectQuality('1080p'),
            ),
            // 일반화질 (720p)
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              title: Text(
                '일반화질 (720p)',
                style: TextStyle(
                  color: MColors.textNormal,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: _selectedQuality == '720p' ? Icon(Icons.check, color: MColors.textNormal) : null,
              onTap: () => _onSelectQuality('720p'),
            ),
            // 저화질 (480p)
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
              title: Text(
                '저화질 (480p)',
                style: TextStyle(
                  color: MColors.textNormal,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: _selectedQuality == '480p' ? Icon(Icons.check, color: MColors.textNormal) : null,
              onTap: () => _onSelectQuality('480p'),
            ),
          ],
        ),
      ),
    );
  }
}
