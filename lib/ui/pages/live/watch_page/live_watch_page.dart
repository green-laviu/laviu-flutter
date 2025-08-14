import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

/// UI만 그리는 목 버전. 데이터/플레이어/소켓 없음.
/// 참고: 기존 라우팅을 깨지 않기 위해 liveId는 받지만 사용하진 않음.
class LiveWatchPage extends StatefulWidget {
  final String liveId;
  const LiveWatchPage({super.key, required this.liveId});

  @override
  State<LiveWatchPage> createState() => _LiveWatchPageState();
}

class _LiveWatchPageState extends State<LiveWatchPage> {
  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();

  // ---- 목 데이터 ----
  late final _LiveMock info;
  final List<_UiChat> messages = [];

  @override
  void initState() {
    super.initState();
    info = _LiveMock(
      id: "live_20250807_01",
      title: "패밀리가 떴다 같이보기 (오늘 짬방)",
      channelName: "다주",
      channelFollowerCount: 207000,
      channelIsFollowing: true,
      viewerCount: 6841,
      badges: const ["talk", "같이보기", "패밀리가떴다"],
      category: "예능",
      tags: const ["오픈 채팅", "공감각적 경험"],
      description: "패밀리 특집 라이브 방송입니다. 함께 봐요!",
      startedAt: DateTime.parse("2025-08-07T15:00:00Z"),
    );

    // 초기 채팅 목
    messages.addAll(const [
      _UiChat(user: "Pepper Zero", text: "오 무야호ㅋㅋㅋ"),
      _UiChat(user: "소고기국밥", text: "진짜 재밌다"),
    ]);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColors.backgroundNormal,
      appBar: AppBar(
        backgroundColor: MColors.backgroundNormal,
        elevation: 0,
        centerTitle: true,
        title: Text('LAVIU', style: MText.heading2(color: MColors.textNormal)),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: MColors.textNeutral,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: MColors.textNeutral,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1) 플레이어 영역(그림만)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Container(color: Colors.black),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Row(
                    children: [
                      _pill('LIVE', const Color(0xFFE53935)),
                      const SizedBox(width: 6),
                      _pill('실시간', Colors.black.withOpacity(0.6)),
                    ],
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Colors.white70,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LinearProgressIndicator(
                    value: 0.6,
                    backgroundColor: Colors.white10,
                    color: MColors.primaryStrong,
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),

          // 2) 메타/채널/채팅 리스트
          Expanded(
            child: CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                // 제목/칩/통계
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.title,
                          style: MText.modal3Bold(color: MColors.textNeutral),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children:
                              [
                                ...info.badges,
                                ...info.tags,
                              ].map((t) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: MColors.lineNormal,
                                    ),
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${_compact(info.viewerCount)}명 시청중',
                              style: MText.caption(
                                color: MColors.textAlternative,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '스트리밍 중',
                              style: MText.caption(
                                color: MColors.textAlternative,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 채널 카드
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: 0,
                      color: MColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: MColors.lineNormal),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: _AvatarFallback(name: info.channelName),
                        title: Text(
                          info.channelName,
                          style: MText.label1SemiBold(
                            color: MColors.textNeutral,
                          ),
                        ),
                        subtitle: Text(
                          '팔로워 ${_compact(info.channelFollowerCount)}',
                          style: MText.caption(color: MColors.textAlternative),
                        ),
                        trailing: TextButton(
                          onPressed: () {},
                          child: Text(
                            info.channelIsFollowing ? '팔로잉' : '팔로우',
                            style: MText.label2Medium(
                              color: info.channelIsFollowing
                                  ? MColors.textAlternative
                                  : MColors.primaryStrong,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                const SliverToBoxAdapter(child: Divider(height: 1)),

                // 채팅 리스트
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final m = messages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${m.user} ',
                                    style: MText.label1Medium(
                                      color: _nameColor(m.user),
                                    ),
                                  ),
                                  TextSpan(
                                    text: m.text,
                                    style: MText.caption(
                                      color: MColors.textNeutral,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      );
                    },
                    childCount: messages.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),

          // 3) 하단 입력바
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: BoxDecoration(
                color: MColors.white,
                border: Border(top: BorderSide(color: MColors.lineNormal)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      minLines: 1,
                      maxLines: 3,
                      style: MText.inputRegular(color: MColors.textNeutral),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '채팅을 입력해주세요.',
                        hintStyle: MText.label2Regular(
                          color: MColors.textDisabled,
                        ),
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
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                    color: MColors.primaryStrong,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add(_UiChat(user: '나', text: text));
    });
    _inputCtrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }
}

/* ---------------- 목 모델 (파일 내부) ---------------- */

class _LiveMock {
  final String id;
  final String title;
  final String channelName;
  final int channelFollowerCount;
  final bool channelIsFollowing;
  final int viewerCount;
  final List<String> badges;
  final String category;
  final List<String> tags;
  final String description;
  final DateTime startedAt;

  _LiveMock({
    required this.id,
    required this.title,
    required this.channelName,
    required this.channelFollowerCount,
    required this.channelIsFollowing,
    required this.viewerCount,
    required this.badges,
    required this.category,
    required this.tags,
    required this.description,
    required this.startedAt,
  });
}

class _UiChat {
  final String user;
  final String text;
  const _UiChat({required this.user, required this.text});
}

/* ---------------- 위젯/헬퍼 ---------------- */

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isEmpty
        ? '?'
        : String.fromCharCode(name.runes.first); // 한글도 안전하게 첫 글자
    return CircleAvatar(
      radius: 20,
      backgroundColor: MColors.lineNormal,
      child: Text(
        initials,
        style: MText.label1SemiBold(color: MColors.textNeutral),
      ),
    );
  }
}

Widget _pill(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text, style: MText.label2Bold(color: Colors.white)),
  );
}

Color _nameColor(String name) {
  final code = name.codeUnits.fold<int>(0, (p, e) => (p + e) & 0xFF);
  final palette = [
    Colors.blue,
    Colors.red,
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.orange,
  ];
  return palette[code % palette.length];
}

String _compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
