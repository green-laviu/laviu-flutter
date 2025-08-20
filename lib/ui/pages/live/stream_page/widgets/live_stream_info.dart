import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/live_stream_vm.dart';
import 'package:laviu_flutter/ui/widgets/m_tag_chip.dart';

class LiveStreamInfo extends ConsumerWidget {
  const LiveStreamInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LiveStreamModel? streamModel = ref.watch(liveStreamProvider);

    if (streamModel == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: MSizes.gapXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            Text(
              streamModel.liveStream.title,
              style: TextStyle(
                fontSize: MSizes.fontXXL,
                fontWeight: FontWeight.w700,
                color: MColors.textWhite,
              ),
            ),
            SizedBox(height: MSizes.gapS),
            // 해시태그
            if (streamModel.liveStream.hashtagList.isEmpty)
              SizedBox.shrink()
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final tag in streamModel.liveStream.hashtagList)
                      Padding(
                        padding: EdgeInsets.only(right: MSizes.gapS),
                        child: MTagChip(label: '#${tag.hashtagName}'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
  }
}
