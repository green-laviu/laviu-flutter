import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/_core/utils/m_hls.dart';

import 'package:laviu_flutter/data/repository/chat_providers.dart';
import 'package:laviu_flutter/data/repository/chat_repository.dart';
import 'package:laviu_flutter/data/repository/live_watch_providers.dart';
import 'package:laviu_flutter/ui/pages/live/watch_page/live_watch_vm.dart';

import 'widgets/live_watch_hls_player.dart';

part 'widgets/live_watch_header.dart';
part 'widgets/live_watch_chat_row.dart';

// 예시 테스트 URL들(하나 골라서 _testUrl에 대입)
const _testUrl =
    'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'; // Big Buck Bunny
// const _testUrl = 'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8';
// const _testUrl = 'https://storage.googleapis.com/shaka-demo-assets/angel-one-hls/hls.m3u8';

class LiveWatchPage extends ConsumerStatefulWidget {
  /// 홈에서 넘겨주는 streamId (String으로 왔으면 그대로, 내부에서 int로 변환)
  final dynamic liveId;
  const LiveWatchPage({super.key, required this.liveId});

  @override
  ConsumerState<LiveWatchPage> createState() => _LiveWatchPageState();
}

class _LiveWatchPageState extends ConsumerState<LiveWatchPage> {
  // origin/streamKey는 실제 진입 시 주입하거나, 라우트 args/리포지토리에서 가져와도 OK
  final String _origin = 'http://host:port';
  late final String _streamKey; // 지금은 테스트 URL을 쓰므로 placeholder로 두어도 OK

  final _listCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();

  // TODO: 실제 주소/토큰으로 교체
  final String _wsUrl = 'ws://host:8080/ws';
  final String _jwt = 'Bearer <YOUR_JWT>';

  (String, String, String) get _args => (_wsUrl, _jwt, _streamKey);

  late final int _streamId;

  @override
  void initState() {
    super.initState();
    // liveId가 String/int 어떤 타입으로 와도 안전하게 처리
    _streamId = (widget.liveId is int)
        ? widget.liveId as int
        : int.tryParse(widget.liveId.toString()) ?? -1;

    // 지금은 hlsUrl 무시하고 overrideMasterUrl을 쓰므로, streamKey는 placeholder로 둬도 무방
    _streamKey = widget.liveId.toString();

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
    // 상세 조회
    final detailAsync = ref.watch(liveWatchDetailProvider(_streamId));

    // 채팅 상태
    final chatState = ref.watch(chatMessagesProvider(_args));
    final connState = ref.watch(chatConnStateProvider(_args));

    // 새 메시지 올 때마다 바닥 고정 (과하지 않게 한 번씩만)
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: MColors.backgroundNormal,
      body: SafeArea(
        bottom: false,
        child: detailAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '방송 정보를 불러오지 못했어요.\n$e',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          data: (live) {
            // -------- 서버 응답(data.live) -> 화면 모델 어댑트 --------
            final info = _toLiveMock(live);

            return Column(
              children: [
                // 비디오 플레이어: hlsUrl 무시, 테스트 URL로 재생
                LiveWatchHlsPlayer(
                  origin: _origin,
                  streamKey: _streamKey,
                  initialQuality: LiveQuality.p1080,
                  overrideMasterUrl: _testUrl, // 👈 테스트용
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
                            if (index == 0) {
                              return LiveWatchHeader(info: info);
                            }

                            // 최신을 아래로 보이게 하려면 reversed 사용
                            final items = chatState.items.reversed.toList();
                            final m = items[index - 1];

                            // ChatMessage -> UiChat 어댑트
                            final ui = UiChat(
                              user:
                                  m.authorNickname +
                                  (m.isStreamer ? ' (방송인)' : ''),
                              text: m.content,
                            );
                            return LiveWatchChatRow(m: ui);
                          },
                        ),
                ),

                // 입력창
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: MColors.white,
                      border: Border(
                        top: BorderSide(color: MColors.lineNormal),
                      ),
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
                            style: MText.inputRegular(
                              color: MColors.textNeutral,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText:
                                  (connState.valueOrNull ==
                                      ChatConnState.connected)
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
                                borderSide: BorderSide(
                                  color: MColors.lineNormal,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(
                                  color: MColors.primary.withOpacity(0.4),
                                ),
                              ),
                            ),
                            enabled:
                                (connState.valueOrNull ==
                                ChatConnState.connected),
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
            );
          },
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

  /// 서버(data.live) -> 화면에서 쓰는 간단 뷰 모델
  LiveMock _toLiveMock(Map<String, dynamic> j) {
    final channel = (j['channel'] as Map?) ?? const {};
    final streamer = (channel['streamer'] as Map?) ?? const {};
    final tags = ((j['hashtagList'] as List?) ?? [])
        .whereType<Map>()
        .map((e) => e['hashtagName']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return LiveMock(
      id: (j['streamId'] ?? '').toString(),
      title: j['title']?.toString() ?? '',
      channelName: streamer['nickname']?.toString() ?? '',
      channelFollowerCount: (channel['followerCount'] is num)
          ? (channel['followerCount'] as num).toInt()
          : 0,
      channelIsFollowing: channel['isFollowing'] == true,
      viewerCount: (j['viewerCount'] is num)
          ? (j['viewerCount'] as num).toInt()
          : 0,
      badges: const <String>[], // 별도 배지 없으면 비워둠
      category: '', // 서버 응답에 없으니 일단 공란
      tags: tags,
      description: '', // 상세 설명이 필요하면 서버 필드 추가 후 매핑
      startedAt: _parseDate(j['startedAt']),
    );
  }

  DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

/* ---------------- 목/뷰 모델 (파일 내부) ---------------- */

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
    return SizedBox(
      height: 34,
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(right: fadeWidth),
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
                      MColors.white,
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
