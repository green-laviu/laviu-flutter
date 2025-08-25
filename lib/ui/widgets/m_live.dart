import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/ui/pages/holder/my/detail_page/widgets/my_detail_badge.dart';
import 'package:laviu_flutter/ui/widgets/m_tag_chip.dart';

class MLive extends StatelessWidget {
  final LiveStream liveStream;

  const MLive(this.liveStream, {super.key});

  @override
  Widget build(BuildContext context) {
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
                    liveStream.thumbnailUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: MColors.backgroundAlternative,
                      alignment: Alignment.center,
                      child: Icon(
                        CupertinoIcons.photo,
                        color: MColors.textAlternative,
                        size: 32,
                      ),
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
                    MyDetailBadge(
                      color: MColors.fillContrast,
                      text: '${liveStream.viewerCount}명',
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: MSizes.gapM),

          // 제목
          Text(
            '${liveStream.title}',
            style: MText.heading4(color: MColors.textStrong),
          ),
          SizedBox(height: MSizes.gapXS),

          // 해시태그
          if (liveStream.hashtagList.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (final tag in liveStream.hashtagList)
                    Padding(
                      padding: EdgeInsets.only(right: MSizes.gapS),
                      child: MTagChip(label: '#${tag.hashtagName}'),
                    ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
