import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';

/// 공용 라이브 카드
class MLiveRow extends StatelessWidget {
  final LiveStream item;
  final VoidCallback? onTap;

  /// 카드 보더 색 (기본: 라인)
  final Color borderColor;

  /// 썸네일 가로폭 (기본 148)
  final double thumbWidth;

  /// 태그 노출 여부
  final bool showTags;

  /// 여백/패딩 커스터마이즈
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const MLiveRow({
    super.key,
    required this.item,
    this.onTap,
    this.borderColor = MColors.lineNormal,
    this.thumbWidth = 148,
    this.showTags = true,
    this.margin = const EdgeInsets.fromLTRB(12, 6, 12, 6),
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
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
                    width: thumbWidth,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        item.thumbnailUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (c, w, p) => p == null
                            ? w
                            : Container(color: MColors.lineNormal),
                        errorBuilder: (c, e, st) => Container(
                          color: MColors.lineNormal,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 24,
                          ),
                        ),
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
                    style: MText.modal3Bold(color: MColors.textNeutral),
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
                          loadingBuilder: (c, w, p) => p == null
                              ? w
                              : Container(
                                  width: 20,
                                  height: 20,
                                  color: MColors.lineNormal,
                                ),
                          errorBuilder: (c, e, st) => Container(
                            width: 20,
                            height: 20,
                            color: MColors.lineNormal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.streamerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MText.caption(color: MColors.textAlternative),
                        ),
                      ),
                    ],
                  ),

                  if (showTags) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 28,
                      child: _TagScroller(tags: item.hashtags),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- helpers ---------------- */

class _TagScroller extends StatelessWidget {
  final List<String> tags;
  const _TagScroller({required this.tags});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: tags.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) => _TagChip(label: tags[i]),
        ),
        // 양쪽 페이드
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [MColors.white, MColors.white.withOpacity(0)],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              width: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [MColors.white.withOpacity(0), MColors.white],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: MColors.lineNormal),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: MText.label2Regular(color: MColors.textAlternative),
      ),
    );
  }
}

String _compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
