import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/ui/pages/live/watch_page/live_watch_page.dart';
import 'package:laviu_flutter/ui/widgets/m_live_row.dart';

class HomeRecommendedList extends StatelessWidget {
  final List<LiveStream> lives;
  const HomeRecommendedList({super.key, required this.lives});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = lives[index];
          return MLiveRow(
            item: item,
            borderColor: MColors.lineNormal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // LiveWatchPage의 liveId 타입이 String이면: item.streamId.toString()
                  builder: (_) =>
                      LiveWatchPage(liveId: item.streamId.toString()),
                ),
              );
            },
          );
        },
        childCount: lives.length,
      ),
    );
  }
}
