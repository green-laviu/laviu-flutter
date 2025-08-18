import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/widgets/my_detail_badge.dart';
import 'package:laviu_flutter/ui/widgets/m_tag_chip.dart';

class MLive extends StatelessWidget {
  const MLive({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String? thumbnailUrl = "https://picsum.photos/200/300";

    return Padding(
      padding: EdgeInsets.fromLTRB(MSizes.gapL, MSizes.gapL, MSizes.gapL, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(MSizes.radiusL),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    thumbnailUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: MColors.backgroundAlternative,
                      alignment: Alignment.center,
                      child: Icon(CupertinoIcons.photo, color: MColors.textAlternative, size: 32),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    // LIVE 배지
                    MyDetailBadge(color: MColors.primaryDanger, text: 'LIVE'),
                    SizedBox(width: MSizes.gapXS),
                    // 시청자수 배지
                    MyDetailBadge(color: MColors.fillContrast, text: '6,438명'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MSizes.gapM),

          // 제목
          Text('패밀리가 떴다 같이보기', style: MText.heading4(color: MColors.textStrong)),
          SizedBox(height: MSizes.gapXS),

          // 해시태그
          Row(
            children: [
              MTagChip(label: '#토크'),
              SizedBox(width: MSizes.gapS),
              MTagChip(label: '#같이보기'),
              SizedBox(width: MSizes.gapS),
              MTagChip(label: '#패밀리가떴다'),
            ],
          ),
        ],
      ),
    );
  }
}
