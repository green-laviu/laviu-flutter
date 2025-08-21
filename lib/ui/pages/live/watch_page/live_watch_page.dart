// live_watch_page.dart
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/data/repository/chat_providers.dart';
import 'package:laviu_flutter/data/repository/chat_repository.dart';
import 'package:laviu_flutter/ui/pages/live/watch_page/live_watch_vm.dart';
import 'widgets/live_watch_hls_player.dart';
import 'package:laviu_flutter/_core/utils/m_hls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'widgets/live_watch_header.dart';
part 'widgets/live_watch_chat_row.dart';

// 예시 테스트 URL들(하나 골라서 _testUrl에 대입)
const _testUrl =
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'; // Big Buck Bunny
// const _testUrl = 'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8';
// const _testUrl = 'https://storage.googleapis.com/shaka-demo-assets/angel-one-hls/hls.m3u8';

class LiveWatchPage extends ConsumerStatefulWidget {
  final String liveId;
  const LiveWatchPage({super.key, required this.liveId});

  @override
  ConsumerState<LiveWatchPage> createState() => _LiveWatchPageState();
}

class _LiveWatchPageState extends ConsumerState<LiveWatchPage> {
  // origin/streamKey는 실제 진입 시 주입하거나, 라우트 args/리포지토리에서 가져와도 OK
  final String _origin = 'http://host:port';
  late final String _streamKey;
  final _listCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();
  final String _wsUrl = 'ws://host:8080/ws'; // TODO: 실제 주소로 교체
  final String _jwt = 'Bearer <YOUR_JWT>'; // TODO: 세션/GVM에서 끌어오세요

  (String, String, String) get _args => (_wsUrl, _jwt, _streamKey);

  // ---- 목 데이터 ----
  late final LiveMock info;
  // final List<UiChat> messages = [];  // 실 데이터는 provider에서 옴

  @override
  void initState() {
    super.initState();
    _streamKey = widget.liveId;

    info = LiveMock(
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

    // messages.addAll(const [
    //   UiChat(user: "Pepper Zero", text: "오 무야호ㅋㅋㅋ"),
    //   UiChat(user: "소고기국밥", text: "진짜 재밌다"),
    // ]);

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
    final chatState = ref.watch(chatMessagesProvider(_args));
    final connState = ref.watch(chatConnStateProvider(_args));

    // 새 메시지 올 때마다 바닥 고정 (과하지 않게 한 번씩만)
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: MColors.backgroundNormal,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LiveWatchHlsPlayer(
              origin: _origin,
              streamKey: _streamKey,
              initialQuality: LiveQuality.p1080,
              overrideMasterUrl: _testUrl,
            ),
            Expanded(
              child: chatState.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _listCtrl,
                      padding: const EdgeInsets.only(top: 0, bottom: 8),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: (chatState.items.length) + 1, // 0 = 헤더
                      itemBuilder: (context, index) {
                        if (index == 0) return LiveWatchHeader(info: info);

                        // 최신을 아래로 보이게 하려면 reversed 사용
                        final items = chatState.items.reversed.toList();
                        final m = items[index - 1];

                        // ChatMessage -> UiChat 어댑트
                        final ui = UiChat(
                          user:
                              m.authorNickname + (m.isStreamer ? ' (방송인)' : ''),
                          text: m.content,
                        );
                        return LiveWatchChatRow(m: ui);
                      },
                    ),
            ),
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
                          hintText:
                              (connState.valueOrNull == ChatConnState.connected)
                              ? '채팅을 입력해주세요.'
                              : '연결 중…',
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
                        enabled:
                            (connState.valueOrNull == ChatConnState.connected),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          (connState.valueOrNull == ChatConnState.connected)
                          ? _send
                          : null,
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

    ref.read(chatMessagesProvider(_args).notifier).send(text);

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

class LiveMock {
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

  LiveMock({
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

class UiChat {
  final String user;
  final String text;
  const UiChat({required this.user, required this.text});
}

/* ---------------- 위젯/헬퍼 ---------------- */

class TagStrip extends StatelessWidget {
  final List<String> items;
  final double fadeWidth;
  const TagStrip({super.key, required this.items, this.fadeWidth = 24});

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

Color nameColor(String name) {
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

String compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
