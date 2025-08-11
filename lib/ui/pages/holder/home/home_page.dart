import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/repository/home_providers.dart';
import 'package:laviu_flutter/ui/pages/holder/home/widgets/index.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/live_preview_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _bannerCtrl = PageController(viewportFraction: 0.92);
  double _bannerPage = 0;

  @override
  void initState() {
    super.initState();
    _bannerCtrl.addListener(() {
      setState(() => _bannerPage = _bannerCtrl.page ?? 0);
    });
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(homeFeedProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: MColors.backgroundNormal,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false, // 뒤로가기 아이콘 자동 노출 방지
            leadingWidth: 48,
            leading: IconButton(
              tooltip: '방송하기',
              icon: const Icon(Icons.videocam_outlined), // 취향껏 아이콘 바꿔도 OK
              color: MColors.textNeutral,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LivePreviewPage()),
                );
              },
            ),
            title: Text('홈', style: MText.heading2(color: MColors.textNormal)),
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
                onPressed: () {},
              ),
            ],
          ),

          ...feedAsync.when(
            data: (feed) => [
              BannerCarousel(
                controller: _bannerCtrl,
                page: _bannerPage,
                items: feed.carousel, // LiveStream 리스트 그대로 전달
              ),
              const SectionTitle(),
              RecommendedList(items: feed.recommended),
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
    );
  }
}
