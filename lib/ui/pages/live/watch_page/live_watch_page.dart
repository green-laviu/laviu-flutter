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
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'widgets/live_watch_header.dart';
part 'widgets/live_watch_chat_row.dart';

class LiveWatchPage extends ConsumerStatefulWidget {
  /// 홈에서 넘겨주는 streamId (String으로 왔으면 그대로, 내부에서 int로 변환)
  final dynamic liveId;
  const LiveWatchPage({super.key, required this.liveId});

  @override
  ConsumerState<LiveWatchPage> createState() => _LiveWatchPageState();
}

class _LiveWatchPageState extends ConsumerState<LiveWatchPage> {
  // TODO: 실제 주소/토큰으로 교체 (채팅용)
  final String _wsUrl = 'ws://host:8080/ws';
  final String _jwt = 'Bearer <YOUR_JWT>';

  final _listCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();

  late final int _streamId;
  late final String _streamKeyForChat; // 채팅 args에 쓰는 키(지금은 streamId string)
  (String, String, String) get _args => (_wsUrl, _jwt, _streamKeyForChat);

  @override
  void initState() {
    super.initState();
    _streamId = (widget.liveId is int)
        ? widget.liveId as int
        : int.tryParse(widget.liveId.toString()) ?? -1;
    _streamKeyForChat = widget.liveId.toString();

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
            // 화면 헤더용 모델
            final info = _toLiveMock(live);

            // HLS 재생 파라미터
            final master = _absoluteHls(live['hlsUrl'] as String?); // 우선 사용
            final origin = dotenv.env['HLS_BASE_URL'] ?? _baseFromApi(8081);
            final streamKey =
                (live['streamKey']?.toString() ?? widget.liveId.toString());

            return Column(
              children: [
                // 비디오 플레이어
                LiveWatchHlsPlayer(
                  origin: origin,
                  streamKey: streamKey,
                  initialQuality: LiveQuality.p1080,
                  overrideMasterUrl: master, // 있으면 마스터 ABR, 없으면 고정식
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
                            final items = chatState.items.reversed.toList();
                            final m = items[index - 1];
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
      badges: const <String>[],
      category: '',
      tags: tags,
      description: '',
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

  // ---------------- HLS 도우미 ----------------

  /// 상대경로로 온 hlsUrl("/hls/abcd.m3u8")을 절대경로로 변환
  String? _absoluteHls(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final v = raw.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    final base = dotenv.env['HLS_BASE_URL'] ?? _baseFromApi(8081);
    return '$base${v.startsWith('/') ? v : '/$v'}';
  }

  /// BASE_URL에서 host를 재사용해 hls 포트(8081)로 베이스 구성
  String _baseFromApi(int port) {
    final api = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8080';
    final u = Uri.tryParse(api);
    if (u == null) return 'http://10.0.2.2:$port';
    final scheme = u.scheme.isEmpty ? 'http' : u.scheme;
    final host = u.host.isEmpty ? '10.0.2.2' : u.host;
    return Uri(scheme: scheme, host: host, port: port).toString();
  }
}

/* ---------------- 목/뷰 모델 ---------------- */

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
                    colors: [MColors.white.withOpacity(0.0), MColors.white],
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
