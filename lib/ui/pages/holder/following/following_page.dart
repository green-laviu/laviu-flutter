import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/model/following.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/data/repository/following_providers.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/live_preview_page.dart';
import 'package:laviu_flutter/ui/pages/live/watch_page/live_watch_page.dart';
import 'package:laviu_flutter/ui/pages/search/search_page.dart';
import 'package:laviu_flutter/ui/widgets/m_live_row.dart';

class FollowingPage extends ConsumerStatefulWidget {
  const FollowingPage({super.key});
  @override
  ConsumerState<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends ConsumerState<FollowingPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tab;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    ); // 0=전체, 1=라이브
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final feedAsync = ref.watch(followingFeedProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: MColors.backgroundNormal,
            elevation: 0,
            centerTitle: true,

            // 홈과 동일한 AppBar 구성
            automaticallyImplyLeading: false,
            leadingWidth: 48,
            leading: IconButton(
              tooltip: '방송하기',
              icon: const Icon(Icons.videocam_outlined),
              color: MColors.textNeutral,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LivePreviewPage()),
                );
              },
            ),
            title: Text(
              'LAVIU',
              style: MText.heading2(color: MColors.textNormal),
            ),
            actions: [
              IconButton(
                tooltip: '알림',
                icon: const Icon(Icons.notifications_none_rounded),
                color: MColors.textNeutral,
                onPressed: () {},
              ),
              IconButton(
                tooltip: '검색',
                icon: const Icon(Icons.search),
                color: MColors.textNeutral,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                },
              ),
            ],

            // 팔로잉 화면 전용: 탭 유지
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: LayoutBuilder(
                builder: (context, c) {
                  // 화면 너비의 8%를 탭 간격으로 (최소 50, 최대 50)
                  final lp = (c.maxWidth * 0.08).clamp(50.0, 50.0);
                  return Center(
                    child: TabBar(
                      controller: _tab,
                      isScrollable: true,
                      labelPadding: EdgeInsets.symmetric(horizontal: lp),
                      // (가능하면) tabAlignment: TabAlignment.center,
                      labelColor: MColors.textNeutral,
                      unselectedLabelColor: MColors.textAlternative,
                      labelStyle: MText.label2Bold(color: MColors.textNeutral),
                      unselectedLabelStyle: MText.label2Regular(
                        color: MColors.textAlternative,
                      ),
                      indicatorColor: MColors.primaryStrong,
                      indicatorWeight: 2,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: '채널'),
                        Tab(text: '라이브'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          ...feedAsync.when(
            data: (feed) => [
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _ChannelTab(channels: feed.channels),
                    _LiveTab(lives: feed.lives),
                  ],
                ),
              ),
            ],
            loading: () => const [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
            error: (e, st) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('팔로잉 데이터를 불러오지 못했어요.\n$e'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------------- Tabs ---------------- */

class _ChannelTab extends StatelessWidget {
  final List<FollowingChannel> channels;
  const _ChannelTab({required this.channels});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemBuilder: (_, i) => _ChannelRow(item: channels[i]),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: channels.length,
    );
  }
}

class _LiveTab extends StatelessWidget {
  final List<LiveStream> lives;
  const _LiveTab({required this.lives});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: lives.length,
      itemBuilder: (_, i) => MLiveRow(
        item: lives[i],
        borderColor: MColors.lineNormal, // 홈과 동일한 카드 스타일
        onTap: () {
          // TODO: live_watch_page 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LiveWatchPage(liveId: lives.toString()),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------- Rows ---------------- */

class _ChannelRow extends StatelessWidget {
  final FollowingChannel item;
  const _ChannelRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isLive = item.streamStatus.toUpperCase() == 'LIVE';

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isLive ? MColors.red : MColors.lineNormal,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                item.streamerProfileImageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 44, height: 44, color: MColors.lineNormal),
              ),
            ),
          ),
          if (isLive)
            Positioned(
              bottom: -4,
              left: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LIVE',
                  style: MText.label2Bold(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        item.streamerName,
        style: MText.modal3Bold(color: MColors.textNeutral),
      ),
      subtitle: Text(
        isLive ? '라이브 중' : '오프라인',
        style: MText.caption(color: MColors.textAlternative),
      ),
      onTap: () {
        // TODO: 채널 상세 이동
      },
    );
  }
}
