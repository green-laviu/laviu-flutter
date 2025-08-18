// live_watch_page.dart
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

/// UI만 그리는 목 버전. 데이터/플레이어/소켓 없음.
class LiveWatchPage extends StatefulWidget {
  final String liveId;
  const LiveWatchPage({super.key, required this.liveId});

  @override
  State<LiveWatchPage> createState() => _LiveWatchPageState();
}

class _LiveWatchPageState extends State<LiveWatchPage> {
  final _listCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();

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

    messages.addAll(const [
      _UiChat(user: "Pepper Zero", text: "오 무야호ㅋㅋㅋ"),
      _UiChat(user: "소고기국밥", text: "진짜 재밌다"),
    ]);

    // 첫 렌더 후 맨 아래로
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    _inputFocus.addListener(() {
      if (_inputFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 80), _scrollToBottom);
      }
    });
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    _inputCtrl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: MColors.backgroundNormal,
      // AppBar 제거
      body: SafeArea(
        bottom: false, // 하단 입력은 따로 SafeArea로 감쌈
        child: Column(
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

            // 2) 메타/채널/채팅 리스트 (reverse)
            Expanded(
              child: ListView.builder(
                controller: _listCtrl,
                padding: const EdgeInsets.only(top: 0, bottom: 8),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: messages.length + 1, // 0번은 헤더
                itemBuilder: (context, index) {
                  if (index == 0)
                    return _HeaderSection(info: info); // 플레이어 바로 아래
                  final m = messages[index - 1]; // 채팅은 정상 순서
                  return _ChatRow(m: m);
                },
              ),
            ),

            // 3) 하단 입력바 (키보드 가림 방지: SafeArea로 처리)
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
                        focusNode: _inputFocus,
                        onTap: _scrollToBottom,
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
    if (!_listCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listCtrl.animateTo(
        _listCtrl.position.maxScrollExtent + 40,
        duration: const Duration(milliseconds: 180),
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

class _HeaderSection extends StatelessWidget {
  final _LiveMock info;
  const _HeaderSection({required this.info});

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
              // (위) title, SizedBox(height: 8) 까지는 그대로 두고,
              // 이 자리의 Wrap(...)을 교체:
              _TagStrip(
                items: [
                  ...info.badges,
                  ...info.tags,
                ],
              ),

              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${_compact(info.viewerCount)}명 시청중',
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
            height: 56, // compact
            child: Row(
              children: [
                // 아바타 (작게)
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

                // 채널명 + 팔로워
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
                        '팔로워 ${_compact(info.channelFollowerCount)}',
                        style: MText.caption(color: MColors.textAlternative),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // 팔로우 버튼 (미니)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text(
                    info.channelIsFollowing ? '팔로잉' : '팔로우',
                    style: MText.label2Medium(
                      color: info.channelIsFollowing
                          ? MColors.textAlternative
                          : MColors.primaryStrong,
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

class _ChatRow extends StatelessWidget {
  final _UiChat m;
  const _ChatRow({required this.m});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ), // 2 -> 6
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${m.user} ',
                  style: MText.label1Medium(color: _nameColor(m.user)),
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

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isEmpty
        ? '?'
        : String.fromCharCode(name.runes.first).toUpperCase(); // 대문자 처리
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

class _TagStrip extends StatelessWidget {
  final List<String> items;
  final double fadeWidth;
  const _TagStrip({required this.items, this.fadeWidth = 24});

  @override
  Widget build(BuildContext context) {
    // Chip 높이에 맞춰 조금 여유를 둔 고정 높이
    return SizedBox(
      height: 34,
      child: Stack(
        children: [
          // 가로 스크롤 되는 태그 줄 (한 줄)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(right: fadeWidth), // 페이드 아래로 살짝 패딩
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

          // 오른쪽 페이드(살짝 넘어가는 느낌)
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
                      MColors.white, // 배경색에 맞춰서 자연스럽게
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

class _ChannelCompactRow extends StatelessWidget {
  final _LiveMock info;
  const _ChannelCompactRow({required this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 56, // 컴팩트 높이
        child: Row(
          children: [
            // 아바타 더 작게
            CircleAvatar(
              radius: 16, // 20 -> 16
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

            // 이름 + 팔로워 (작게)
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
                    '팔로워 ${_compact(info.channelFollowerCount)}',
                    style: MText.caption(color: MColors.textAlternative),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 팔로우 버튼 (미니)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32), // 낮은 높이
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(
                info.channelIsFollowing ? '팔로잉' : '팔로우',
                style: MText.label2Medium(
                  color: info.channelIsFollowing
                      ? MColors.textAlternative
                      : MColors.primaryStrong,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
