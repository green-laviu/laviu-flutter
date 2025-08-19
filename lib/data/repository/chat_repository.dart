import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../model/chat_message.dart';
import '../model/participant.dart';

enum ChatConnState { idle, connecting, connected, error, closed }

class ChatRepository {
  ChatRepository({
    required this.wsUrl, // ws://host:8080/ws (운영은 wss://)
    required this.jwt, // Authorization 헤더 값 (예: 'Bearer xxx')
    required this.streamKey,
    this.useSockJS = false, // 서버가 SockJS면 true
    this.mockMode = false, // ✅ 목 모드 ON/OFF
  });

  final String wsUrl;
  final String jwt;
  final String streamKey;
  final bool useSockJS;
  final bool mockMode;

  bool get isMock => mockMode;

  StompClient? _client;

  // Streams
  final _connStateCtrl = StreamController<ChatConnState>.broadcast();
  final _chatCtrl = StreamController<ChatMessage>.broadcast();
  final _participantsCtrl = StreamController<List<Participant>>.broadcast();
  final _notifCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<ChatConnState> get connState => _connStateCtrl.stream;
  Stream<ChatMessage> get chatStream => _chatCtrl.stream; // 실시간 단건 스트림(서버용)
  Stream<List<Participant>> get participantsStream => _participantsCtrl.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notifCtrl.stream;

  bool get isConnected => _client?.connected == true;

  // ----------------- MOCK STORE (타이머 없음) -----------------
  // _mockStore: "오래된 → 최신" 순으로 쌓아둠
  final List<ChatMessage> _mockStore = [];
  final _rng = Random();
  static const _mockAuthors = ['ssar', 'dori', 'hana', 'zero', 'mint', '콩자'];
  static const _mockTexts = [
    '안녕하세요!',
    'ㅋㅋㅋㅋ',
    '오 이 장면 레전드',
    '오늘도 화이팅',
    '와... 뭐야 방금',
    '좋아요 눌렀습니다',
  ];

  void _ensureMockSeeded({int total = 80}) {
    if (_mockStore.isNotEmpty) return;
    final now = DateTime.now();
    // 오래된 → 최신
    for (int i = total - 1; i >= 0; i--) {
      final nick = _mockAuthors[_rng.nextInt(_mockAuthors.length)];
      _mockStore.add(
        ChatMessage(
          authorId: 100 + i,
          authorNickname: nick,
          emailId: nick,
          isStreamer: (i % 13 == 0),
          content: _mockTexts[_rng.nextInt(_mockTexts.length)],
          timestamp: now.subtract(Duration(seconds: (total - i) * 5)),
        ),
      );
    }
  }

  /// 최신 N개(기본 30)를 "최신→오래된" 순서로 반환 (UI state가 최신-우선이므로)
  List<ChatMessage> _latestBatch({int limit = 30}) {
    _ensureMockSeeded();
    final len = _mockStore.length;
    final start = (len - limit) < 0 ? 0 : (len - limit);
    final slice = _mockStore.sublist(start, len); // 오래된→최신
    return slice.reversed.toList(); // 최신→오래된 (state 규칙과 일치)
  }

  /// (목) 전송 반영: 내 메시지를 최신으로 추가하고, 최신 30개 반환
  List<ChatMessage> mockApplySendAndGetBatch(String content, {int limit = 30}) {
    _ensureMockSeeded();
    final msg = ChatMessage(
      authorId: -1,
      authorNickname: '나',
      emailId: 'me',
      isStreamer: false,
      content: content.trim(),
      timestamp: DateTime.now(),
    );
    _mockStore.add(msg); // 최신 끝에 추가
    return _latestBatch(limit: limit);
  }

  /// (목) 초기/재요청 배치
  List<ChatMessage> mockGetLatestBatch({int limit = 30}) =>
      _latestBatch(limit: limit);
  // -----------------------------------------------------------

  // ----------------- 실서버 연결 -----------------
  void connect() {
    // ✅ 목 모드: STOMP 연결 없이 "연결됨" 신호만 주고 끝
    if (mockMode) {
      _connStateCtrl.add(ChatConnState.connecting);
      Future.delayed(const Duration(milliseconds: 200), () {
        _connStateCtrl.add(ChatConnState.connected);
      });
      return;
    }

    if (isConnected) return;
    _connStateCtrl.add(ChatConnState.connecting);

    final cfg = useSockJS
        ? StompConfig.sockJS(
            url: wsUrl,
            stompConnectHeaders: {'Authorization': jwt},
            webSocketConnectHeaders: {'Authorization': jwt},
            onConnect: _onConnect,
            onDisconnect: _onDisconnect,
            onWebSocketError: _onWsError,
            onStompError: _onStompError,
            heartbeatIncoming: const Duration(seconds: 15),
            heartbeatOutgoing: const Duration(seconds: 15),
            reconnectDelay: const Duration(seconds: 3),
          )
        : StompConfig(
            url: wsUrl,
            stompConnectHeaders: {'Authorization': jwt},
            webSocketConnectHeaders: {'Authorization': jwt},
            onConnect: _onConnect,
            onDisconnect: _onDisconnect,
            onWebSocketError: _onWsError,
            onStompError: _onStompError,
            heartbeatIncoming: const Duration(seconds: 15),
            heartbeatOutgoing: const Duration(seconds: 15),
            reconnectDelay: const Duration(seconds: 3),
          );

    _client = StompClient(config: cfg)..activate();
  }

  void _onConnect(StompFrame frame) {
    _connStateCtrl.add(ChatConnState.connected);

    // 서버가 30개 배치를 한 번에 준다면, 여기서는 보통 단일 프레임이 아니라
    // 별도 REST/프레임 규약이 필요할 수 있음. (현재는 실시간 단건 스트림만 구독)
    _client?.subscribe(
      destination: '/sub/streams/$streamKey/chats',
      callback: (f) {
        final body = f.body;
        if (body == null) return;
        _chatCtrl.add(ChatMessage.fromJson(jsonDecode(body)));
      },
    );

    _client?.subscribe(
      destination: '/sub/streams/$streamKey/participants',
      callback: (f) {
        final body = f.body;
        if (body == null) return;
        final list = (jsonDecode(body) as List)
            .map((e) => Participant.fromJson(e))
            .toList();
        _participantsCtrl.add(list);
      },
    );

    _client?.subscribe(
      destination: '/user/queue/notifications',
      callback: (f) {
        final body = f.body;
        if (body == null) return;
        _notifCtrl.add(jsonDecode(body));
      },
    );

    join();
  }

  void _onDisconnect(StompFrame frame) {
    _connStateCtrl.add(ChatConnState.closed);
  }

  void _onWsError(dynamic error) {
    _connStateCtrl.add(ChatConnState.error);
  }

  void _onStompError(StompFrame frame) {
    _connStateCtrl.add(ChatConnState.error);
  }

  /// 메시지 발행
  void sendChat(String content) {
    final text = content.trim();
    if (text.isEmpty) return;

    if (mockMode) {
      // 목 모드에서는 스트림으로 흘리지 않음 (배치 교체는 VM에서 set)
      // 단, 내부 스토어에는 반영해 둔다.
      mockApplySendAndGetBatch(text);
      return;
    }

    if (!isConnected) return;
    _client?.send(
      destination: '/pub/streams/$streamKey/chats',
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'content': text}),
    );
  }

  /// 채팅 채널 참가
  void join() {
    if (mockMode) {
      // 목 모드에서는 별도 작업 없음 (VM에서 배치 로드)
      return;
    }
    if (!isConnected) return;
    _client?.send(
      destination: '/pub/streams/$streamKey/join',
      headers: {'content-type': 'application/json'},
      body: '{}',
    );
  }

  /// 연결 해제
  Future<void> disconnect() async {
    if (mockMode) {
      _connStateCtrl.add(ChatConnState.closed);
      return;
    }
    _client?.deactivate();
    _client = null;
    _connStateCtrl.add(ChatConnState.closed);
  }

  /// 리소스 정리
  void dispose() {
    _connStateCtrl.close();
    _chatCtrl.close();
    _participantsCtrl.close();
    _notifCtrl.close();
  }
}
