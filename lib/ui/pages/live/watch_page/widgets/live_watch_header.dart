part of 'package:laviu_flutter/ui/pages/live/watch_page/live_watch_page.dart';

class LiveWatchHeader extends StatelessWidget {
  final LiveMock info;
  const LiveWatchHeader({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 제목/칩/통계
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.title,
                style: MText.modal3Bold(color: MColors.textNeutral),
              ),
              const SizedBox(height: 8),
              TagStrip(items: [...info.badges, ...info.tags]),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${compact(1)}명 시청중', // TODO : 시연영상용 1 고정 -> 원래 값 : info.viewerCount
                    style: MText.caption(color: MColors.textAlternative),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '스트리밍 중',
                    style: MText.caption(color: MColors.textAlternative),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 채널 카드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: MColors.lineNormal,
                  child: Text(
                    info.channelName.isEmpty
                        ? '?'
                        : String.fromCharCode(
                            info.channelName.runes.first,
                          ).toUpperCase(),
                    style: MText.label2Medium(color: MColors.textNeutral),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.channelName,
                        style: MText.label1SemiBold(color: MColors.textNeutral),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '팔로워 ${compact(info.channelFollowerCount)}',
                        style: MText.caption(color: MColors.textAlternative),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text(
                    info.channelIsFollowing ? '팔로잉' : '팔로우',
                    style: MText.label2Medium(
                      color: info.channelIsFollowing ? MColors.textAlternative : MColors.primaryStrong,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Divider(
          height: 0.5,
          thickness: 0.5,
          color: MColors.lineNormal.withOpacity(0.18),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ---------------- TagStrip (간단 태그 스크롤) ----------------
class TagStrip extends StatelessWidget {
  final List<String> items;
  final double fadeWidth;
  const TagStrip({super.key, required this.items, this.fadeWidth = 24});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(height: 0);
    }

    return SizedBox(
      height: 34,
      child: Stack(
        children: [
          // 가로 스크롤 태그 나열
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(right: fadeWidth),
            child: Row(
              children: [
                const SizedBox(width: 2),
                ...items.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: MColors.lineNormal),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t,
                        style: MText.label2Regular(
                          color: MColors.textAlternative,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
              ],
            ),
          ),

          // 오른쪽 페이드(넘치는 느낌)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: fadeWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      MColors.white.withOpacity(0.0),
                      MColors.white,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
