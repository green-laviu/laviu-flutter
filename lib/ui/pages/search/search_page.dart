import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/model/search.dart';
import 'package:laviu_flutter/data/repository/search_providers.dart';
import 'package:laviu_flutter/ui/pages/live/watch_page/live_watch_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
    _tab = TabController(
      length: 2,
      vsync: this,
      initialIndex: ref.read(searchTabIndexProvider),
    );
    _tab.addListener(
      () => ref.read(searchTabIndexProvider.notifier).state = _tab.index,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _tab.dispose();
    super.dispose();
  }

  void _submit() {
    ref.read(searchQueryProvider.notifier).state = _controller.text.trim();
    ref.refresh(searchResponseProvider);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(searchResponseProvider);

    return Scaffold(
      backgroundColor: MColors.backgroundNormal,
      appBar: AppBar(
        backgroundColor: MColors.backgroundNormal,
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 42,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: MColors.textNeutral,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () => Navigator.pop(context),
        ),
        title: _SearchField(
          controller: _controller,
          onSubmitted: (_) => _submit(),
        ),
        // 돋보기는 필드 안으로 옮겼으니 actions 비움
        actions: const [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              labelColor: MColors.textNeutral,
              unselectedLabelColor: MColors.textAlternative,
              labelStyle: MText.label2Bold(color: MColors.textNeutral),
              unselectedLabelStyle: MText.label2Regular(
                color: MColors.textAlternative,
              ),
              indicatorColor: MColors.primaryStrong,
              tabs: const [
                Tab(text: '채널'),
                Tab(text: '라이브'),
              ],
            ),
          ),
        ),
      ),

      body: async.when(
        data: (d) => Column(
          children: [
            if (d.suggestions.isNotEmpty)
              _SuggestionRow(
                suggestions: d.suggestions,
                onTap: (s) {
                  _controller.text = s;
                  _submit();
                },
              ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _ChannelList(items: d.channels),
                  _LiveList(items: d.lives),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '검색 결과를 불러오지 못했어요.\n$e',
            style: MText.label1Medium(color: MColors.textNeutral),
          ),
        ),
      ),
    );
  }
}

/* ---------------- widgets ---------------- */

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  const _SearchField({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8, 8, 8), // 왼쪽 0: X 아이콘과 더 붙이기
      child: SizedBox(
        height: 40,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller, // 입력 변화에 따른 X 토글
          builder: (context, value, _) {
            final hasText = value.text.isNotEmpty;
            return TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: MText.inputRegular(color: MColors.textNeutral),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: MColors.white,
                hintText: '채널, 라이브, 동영상 검색',
                hintStyle: MText.label2Regular(color: MColors.textDisabled),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(color: MColors.lineNormal),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide(
                    color: MColors.primary.withOpacity(0.4),
                  ),
                ),

                // 기본 48px 여백 제거
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                // ⬇︎ 아이콘 간격을 직접 제어
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasText)
                      GestureDetector(
                        onTap: () => controller.clear(),
                        child: const Padding(
                          padding: EdgeInsets.only(
                            right: 12,
                          ), // 검색간격 조절
                          child: Icon(Icons.clear, size: 18),
                        ),
                      ),
                    GestureDetector(
                      onTap: () => onSubmitted(controller.text),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 6), // 오른쪽 끝 여백 최소화
                        child: Icon(Icons.search, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;
  const _SuggestionRow({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => onTap(suggestions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: MColors.lineNormal),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                suggestions[i],
                style: MText.label2Regular(
                  color: MColors.textAlternative,
                ),
              ),
            ),
          ),
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemCount: suggestions.length,
        ),
      ),
    );
  }
}

class _ChannelList extends StatelessWidget {
  final List<ChannelResult> items;
  const _ChannelList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (_, i) => _ChannelRow(item: items[i]),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
    );
  }
}

class _ChannelRow extends StatefulWidget {
  final ChannelResult item;
  const _ChannelRow({required this.item});
  @override
  State<_ChannelRow> createState() => _ChannelRowState();
}

class _ChannelRowState extends State<_ChannelRow> {
  late bool following;
  @override
  void initState() {
    super.initState();
    following = widget.item.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return ListTile(
      leading: ClipOval(
        child: Image.network(
          item.thumbnailUrl,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(width: 44, height: 44, color: MColors.lineNormal),
        ),
      ),
      title: Text(
        item.name,
        style: MText.modal3Bold(color: MColors.textNeutral),
      ),
      subtitle: Text(
        '팔로워 ${item.followerCount}',
        style: MText.caption(color: MColors.textAlternative),
      ),
      trailing: TextButton(
        onPressed: () => setState(() => following = !following),
        child: Text(
          following ? '팔로잉' : '팔로우',
          style: MText.label2Medium(color: MColors.primaryStrong),
        ),
      ),
    );
  }
}

class _LiveList extends StatelessWidget {
  final List<LiveResult> items;
  const _LiveList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => _LiveRow(item: items[i]),
    );
  }
}

class _LiveRow extends StatelessWidget {
  final LiveResult item;
  const _LiveRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final dynamic liveId = int.tryParse(item.id) ?? item.id; // int/문자열 모두 허용

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6), // 기존 margin
      child: Material(
        color: MColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: MColors.lineNormal),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LiveWatchPage(liveId: liveId)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10), // 기존 padding
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 132,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            item.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: MColors.lineNormal),
                          ),
                        ),
                      ),
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
                                _compact(item.viewers),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: MText.modal3Bold(color: MColors.textNeutral),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.channelName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MText.caption(color: MColors.textAlternative),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 28,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, i) => Container(
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
                              item.badges[i],
                              style: MText.label2Regular(
                                color: MColors.textAlternative,
                              ),
                            ),
                          ),
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemCount: item.badges.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
