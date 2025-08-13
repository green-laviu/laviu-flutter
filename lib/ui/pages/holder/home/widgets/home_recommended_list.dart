import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/ui/widgets/m_live_row.dart';

class HomeRecommendedList extends StatelessWidget {
  final List<LiveStream> items;
  const HomeRecommendedList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => MLiveRow(
          item: items[index],
          borderColor: MColors.lineNormal,
          onTap: () {
            // TODO: live_watch_page로 이동
          },
        ),
        childCount: items.length,
      ),
    );
  }
}
