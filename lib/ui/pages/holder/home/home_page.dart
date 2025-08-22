import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/repository/home_providers.dart';

import 'package:laviu_flutter/ui/pages/holder/home/widgets/home_index.dart';
import 'package:laviu_flutter/ui/pages/live/streaming_page/live_streaming_page.dart';
import 'package:laviu_flutter/ui/pages/notification/notification_page.dart';
import 'package:laviu_flutter/ui/pages/search/search_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  final _bannerCtrl = PageController(viewportFraction: 0.92);
  double _bannerPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bannerCtrl.addListener(() {
      setState(() => _bannerPage = _bannerCtrl.page ?? 0);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerCtrl.dispose();
    super.dispose();
  }

  /// 앱이 백그라운드 → 포그라운드로 돌아왔을 때, 최신 홈 피드 다시 로드
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // invalidate: 다음 빌드에서 새로 fetch
      ref.invalidate(homeFeedProvider);
    }
    super.didChangeAppLifecycleState(state);
  }

  /// 당겨서 새로고침 / 스트리밍 복귀 후 리프레시에 사용
  Future<void> _refresh() {
    // refresh(...future) 는 바로 재요청 Future를 반환
    return ref.refresh(homeFeedProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(homeFeedProvider);

    return SafeArea(
      child: RefreshIndicator.adaptive(
        color: MColors.primaryStrong,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: MColors.backgroundNormal,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leadingWidth: 48,
              leading: IconButton(
                tooltip: '방송하기',
                icon: const Icon(Icons.videocam_outlined),
                color: MColors.textNeutral,
                onPressed: () async {
                  // 스트리밍 페이지로 이동 → 복귀 시 홈 피드 리프레시
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LiveStreamingPage()),
                  );
                  if (!mounted) return;
                  await _refresh();
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationPage()),
                    );
                  },
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
            ),

            ...feedAsync.when(
              data: (feed) => [
                HomeBannerCarousel(
                  controller: _bannerCtrl,
                  page: _bannerPage,
                  items: feed.carousel,
                ),
                const HomeSectionTitle(),
                HomeRecommendedList(lives: feed.recommended),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '홈 데이터를 불러오지 못했어요.\n$e',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
