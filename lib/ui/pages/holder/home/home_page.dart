import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/data/repository/home_providers.dart';

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
            title: Text('홈', style: MText.heading2(color: MColors.textNormal)),
            centerTitle: true,
            backgroundColor: MColors.backgroundNormal,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {}, // TODO: 검색
                icon: const Icon(Icons.search),
                color: MColors.textNeutral,
              ),
              IconButton(
                onPressed: () {}, // TODO: 알림
                icon: const Icon(Icons.notifications_none_rounded),
                color: MColors.textNeutral,
              ),
            ],
          ),

          ...feedAsync.when(
            data: (feed) => [
              _BannerCarousel(
                controller: _bannerCtrl,
                page: _bannerPage,
                banners: feed.carousel.map((e) => e.thumbnailUrl).toList(),
              ),
              const _SectionTitle(),
              _RecommendedList(items: feed.recommended),
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

/* ---------- 위젯들 ---------- */

class _BannerCarousel extends StatelessWidget {
  final PageController controller;
  final double page;
  final List<String> banners;

  const _BannerCarousel({
    required this.controller,
    required this.page,
    required this.banners,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: SizedBox(
              height: 180,
              child: PageView.builder(
                controller: controller,
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final selected = (index - page).abs() < 0.6;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            selected ? 0.12 : 0.06,
                          ),
                          blurRadius: selected ? 14 : 6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              banners[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          // 그라데이션 오버레이
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withOpacity(0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 좌하단 배지/텍스트
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MColors.primaryStrong,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'LIVE',
                                    style: MText.label2Bold(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '지금 라이브 중',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: MColors.textNeutral,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              final active = (i - page).abs() < 0.5;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? MColors.textNeutral : MColors.textAlternative,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '이 방송 어때요?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: MColors.textNeutral,
                ),
              ),
            ),
            TextButton(
              onPressed: () {}, // TODO: 더보기
              child: Text(
                '더보기',
                style: MText.label2Bold(color: MColors.primaryStrong),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedList extends StatelessWidget {
  final List<LiveStream> items;
  const _RecommendedList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _LiveRow(
          item: items[index],
          borderColor: index == 0 ? MColors.primaryStrong : MColors.lineNormal,
          onTap: () {
            // TODO: live_watch_page로 이동
          },
        ),
        childCount: items.length,
      ),
    );
  }
}

class _LiveRow extends StatelessWidget {
  final LiveStream item;
  final VoidCallback onTap;
  final Color borderColor;

  const _LiveRow({
    required this.item,
    required this.onTap,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: MColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일 (16:9)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  SizedBox(
                    width: 148,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        item.thumbnailUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 좌상단 시청자 수
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _compact(item.viewerCount),
                            style: MText.label2Bold(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 오른쪽 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: MColors.textNeutral,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 스트리머 (아바타 + 이름)
                  Row(
                    children: [
                      ClipOval(
                        child: Image.network(
                          item.streamerProfileImageUrl,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item.streamerName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MColors.textAlternative,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 태그
                  Wrap(
                    spacing: 6,
                    runSpacing: -6,
                    children: item.hashtags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: MColors.lineNormal),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t,
                          style: MText.label2Regular(
                            color: MColors.textAlternative,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _compact(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
