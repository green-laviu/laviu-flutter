import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/widgets/m_tag_chip.dart';

class LiveStreamInfo extends StatelessWidget {
  const LiveStreamInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MSizes.gapXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '제목',
            style: TextStyle(
              fontSize: MSizes.fontXXL,
              fontWeight: FontWeight.w700,
              color: MColors.textWhite,
            ),
          ),
          SizedBox(height: MSizes.gapS),
          // 해시태그
          Row(
            children: [
              MTagChip(label: '#소통방송'),
              SizedBox(width: MSizes.gapS),
              MTagChip(label: '#해시'),
              SizedBox(width: MSizes.gapS),
              MTagChip(label: '#태그'),
            ],
          ),
        ],
      ),
    );
  }
}
