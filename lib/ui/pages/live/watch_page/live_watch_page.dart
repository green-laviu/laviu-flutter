// lib/ui/pages/live/watch_page/live_watch_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/_core/utils/m_hls.dart';
import 'package:laviu_flutter/data/repository/live_watch_providers.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_input_bar.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_chat_list.dart';

import 'widgets/live_watch_hls_player.dart';

part 'widgets/live_watch_chat_row.dart';
// ⬇️ 채팅은 UI(행 렌더러)만 남긴다.
part 'widgets/live_watch_header.dart';

class LiveWatchPage extends ConsumerStatefulWidget {
  /// 홈에서 넘겨주는 streamId (String/int 모두 허용)
  final dynamic liveId;
  const LiveWatchPage({super.key, required this.liveId});

  @override
  ConsumerState<LiveWatchPage> createState() => _LiveWatchPageState();
}

class _LiveWatchPageState extends ConsumerState<LiveWatchPage> {
  // --------- 채팅: UI만 남기고 내부 로컬 메모리만 사용 ---------
  final _listCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final _inputFocus = FocusNode();
  final List<UiChat> _messages = []; // 오래된 → 최신 순으로 보관

  // --------- 상세/HLS 관련 ---------
  late final int _streamId;

  @override
  void initState() {
    super.initState();

    // streamId 정규화
    _streamId = (widget.liveId is int) ? widget.liveId as int : int.tryParse(widget.liveId.toString()) ?? -1;

    // 입력창 포커스 시 살짝 내려주기
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
    // 상세 조회 (그대로 유지: 비디오/헤더용)
    final detailAsync = ref.watch(liveWatchDetailProvider(_streamId));
    final scrollCtrl = ScrollController();
    final msgCtrl = TextEditingController();

    // 새 메시지 올 때마다 바닥 고정
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
            final info = _toLiveMock(live);

            final master = _absoluteHls(live['hlsUrl'] as String?);
            final origin = dotenv.env['HLS_BASE_URL'] ?? _baseFromApi(8081);
            final streamKey = (live['streamKey']?.toString() ?? widget.liveId.toString());

            // 여기부터 Column 내부 전체
            return Column(
              children: [
                // 비디오
                LiveWatchHlsPlayer(
                  origin: origin,
                  streamKey: streamKey,
                  initialQuality: LiveQuality.p1080,
                  overrideMasterUrl: master,
                ),

                // 빠졌던 방송정보(제목/태그/채널 카드) 다시 추가
                LiveWatchHeader(info: info),

                // 채팅 리스트 (팀원 스타일)
                Expanded(
                  child: LiveStreamChatList(
                    scrollCtrl: scrollCtrl, // 필요시 상태로 빼도 OK
                    streamKey: streamKey,
                    streamId: _streamId,
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
                    child: LiveStreamChatInputBar(
                      msgCtrl: msgCtrl, // 필요시 상태로 빼도 OK
                      scrollCtrl: scrollCtrl,
                      streamKey: streamKey,
                      streamId: _streamId,
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

    // 💬 연결/레포 없이 로컬로만 추가 (UI 확인용)
    final mine = UiChat(user: '나', text: text);
    setState(() => _messages.add(mine));

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

  /// 서버(data.live) -> 화면에서 쓰는 간단 뷰 모델 (헤더용)
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
      channelFollowerCount: (channel['followerCount'] is num) ? (channel['followerCount'] as num).toInt() : 0,
      channelIsFollowing: channel['isFollowing'] == true,
      viewerCount: (j['viewerCount'] is num) ? (j['viewerCount'] as num).toInt() : 0,
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

/* ---------------- 목/뷰 모델(헤더·채팅 UI 의존) ---------------- */

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

/// 채팅 닉네임 색상 (채팅 행에서 사용)
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

/// 수치 압축 표기 (헤더에서 사용)
String compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
