part of 'package:laviu_flutter/ui/pages/live/watch_page/live_watch_page.dart';

class LiveWatchChatRow extends StatelessWidget {
  final UiChat m;
  const LiveWatchChatRow({super.key, required this.m});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${m.user} ',
                  style: MText.label1Medium(color: nameColor(m.user)),
                ),
                TextSpan(
                  text: m.text,
                  style: MText.caption(color: MColors.textNeutral),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
