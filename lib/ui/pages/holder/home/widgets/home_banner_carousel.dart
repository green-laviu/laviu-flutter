import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';

class HomeBannerCarousel extends StatelessWidget {
  final PageController controller;
  final double page;
  final List<LiveStream> items;

  const HomeBannerCarousel({
    super.key,
    required this.controller,
    required this.page,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox(height: 0));
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: SizedBox(
              height: 180,
              child: PageView.builder(
                controller: controller,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = (index - page).abs() < 0.6;

                  final thumb = item.thumbnailUrl;
                  final nickname = item.streamerName ?? '';
                  final avatar = item.streamerProfileImageUrl;
                  final viewers = item.viewerCount ?? 0;

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
                          // 썸네일 (null/404 대비)
                          Positioned.fill(
                            child: (thumb == null || thumb.isEmpty)
                                ? Container(
                                    color: MColors.lineNormal,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '이미지를 불러올 수 없어요',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: MColors.textAlternative,
                                          ),
                                    ),
                                  )
                                : Image.network(
                                    thumb,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: MColors.lineNormal,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '이미지를 불러올 수 없어요',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: MColors.textAlternative,
                                            ),
                                      ),
                                    ),
                                  ),
                          ),

                          // 상단 좌측: LIVE + 시청자수
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Row(
                              children: [
                                _pill(
                                  child: Text(
                                    'LIVE',
                                    style: MText.label2Bold(
                                      color: Colors.white,
                                    ),
                                  ),
                                  color: const Color(0xFFE53935),
                                ),
                                const SizedBox(width: 6),
                                _pill(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.remove_red_eye,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_compact(viewers)}명',
                                        style: MText.label2Bold(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  color: Colors.black.withOpacity(0.55),
                                ),
                              ],
                            ),
                          ),

                          // 하단 그라데이션
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withOpacity(0.45),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 하단 좌측: 제목 + (아바타, 닉네임, 태그)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 제목
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                ),
                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    ClipOval(
                                      child: (avatar == null || avatar.isEmpty)
                                          ? Container(
                                              width: 18,
                                              height: 18,
                                              color: Colors.white24,
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.person,
                                                size: 12,
                                                color: Colors.white70,
                                              ),
                                            )
                                          : Image.network(
                                              avatar,
                                              width: 18,
                                              height: 18,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    width: 18,
                                                    height: 18,
                                                    color: Colors.white24,
                                                  ),
                                            ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        nickname.isEmpty ? '스트리머' : nickname,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.95,
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ...item.hashtags
                                        .take(2)
                                        .map(
                                          (t) => Padding(
                                            padding: const EdgeInsets.only(
                                              left: 6,
                                            ),
                                            child: _chip(t),
                                          ),
                                        ),
                                  ],
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
            children: List.generate(items.length, (i) {
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

/* ---------------- helpers ---------------- */

Widget _pill({required Widget child, required Color color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );
}

Widget _chip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withOpacity(0.22)),
    ),
    child: Text(
      text,
      style: MText.label2Regular(color: Colors.white),
    ),
  );
}

String _compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
