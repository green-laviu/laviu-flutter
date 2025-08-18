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
        (context, index) => MLiveRow(
          item: lives[index],
          borderColor: MColors.lineNormal,
          onTap: () {
            // TODO: live_watch_page로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LiveWatchPage(liveId: lives.toString()),
              ),
            );
          },
        ),
        childCount: lives.length,
      ),
    );
  }
}
