import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../model/chat_message.dart';
import '../model/participant.dart';

enum ChatConnState { idle, connecting, connected, error, closed }

class ChatRepository {
  ChatRepository({
    required this.wsUrl, // 예: ws://host:8080/ws (운영은 wss://)
    required this.jwt, // Authorization 헤더 값 (예: 'Bearer xxx')
    required this.streamKey,
    this.useSockJS = false, // 서버가 SockJS면 true
  });

  final String wsUrl;
  final String jwt;
  final String streamKey;
  final bool useSockJS;

  StompClient? _client;

  /// 상태/데이터 스트림
  final _connStateCtrl = StreamController<ChatConnState>.broadcast();
  final _chatCtrl = StreamController<ChatMessage>.broadcast();
  final _participantsCtrl = StreamController<List<Participant>>.broadcast();
  final _notifCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<ChatConnState> get connState => _connStateCtrl.stream;
  Stream<ChatMessage> get chatStream => _chatCtrl.stream;
  Stream<List<Participant>> get participantsStream => _participantsCtrl.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notifCtrl.stream;

  bool get isConnected => _client?.connected == true;

  /// 연결
  void connect() {
    if (isConnected) return;
    _connStateCtrl.add(ChatConnState.connecting);

    final cfg = useSockJS
        ? StompConfig.sockJS(
            // ⬅️ 소문자 s
            url: wsUrl,
            stompConnectHeaders: {'Authorization': jwt},
            webSocketConnectHeaders: {'Authorization': jwt}, // Web에선 미지원
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

    // 채팅 구독
    _client?.subscribe(
      destination: '/sub/streams/$streamKey/chats',
      callback: (f) {
        final body = f.body;
        if (body == null) return;
        _chatCtrl.add(ChatMessage.fromJson(jsonDecode(body)));
      },
    );

    // 시청자 목록(스트리머만 수신)
    _client?.subscribe(
      destination: '/sub/streams/$streamKey/participants',
      callback: (f) {
        final body = f.body;
        if (body == null) return;
        final list = (jsonDecode(body) as List).map((e) => Participant.fromJson(e)).toList();
        _participantsCtrl.add(list);
      },
    );

    // 개인 알림(제재 등)
    _client?.subscribe(
      destination: '/user/queue/notifications',
      callback: (f) {
        final body = f.body;
        if (body == null) return;
        _notifCtrl.add(jsonDecode(body));
      },
    );

    // 입장 알림(필요 시)
    join();
  }

  void _onDisconnect(StompFrame frame) {
    _connStateCtrl.add(ChatConnState.closed);
  }

  void _onWsError(dynamic error) {
    print('WS error: $error');
  }

  void _onStompError(StompFrame frame) {
    _connStateCtrl.add(ChatConnState.error);
  }

  /// 메시지 발행
  void sendChat(String content) {
    if (!isConnected || content.trim().isEmpty) return;
    _client?.send(
      destination: '/pub/streams/$streamKey/chats',
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'content': content.trim()}),
    );
  }

  /// 채팅 채널 참가
  void join() {
    if (!isConnected) return;
    _client?.send(
      destination: '/pub/streams/$streamKey/join',
      headers: {'content-type': 'application/json'},
      body: '{}',
    );
  }

  /// 연결 해제
  Future<void> disconnect() async {
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
