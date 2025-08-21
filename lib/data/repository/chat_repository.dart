import 'dart:async';
import 'dart:convert';

import 'package:laviu_flutter/_core/utils/m_device.dart';
import 'package:laviu_flutter/data/model/chat_message.dart';
import 'package:logger/logger.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRepository {
  StompClient? _client;
  StompUnsubscribe? _sub;
  String? _streamKey;

  // 서버 주소
  final String wsUrl = "ws://192.168.0.133:8080/ws";

  /// 외부(Riverpod VM)에서 주입할 수신 콜백
  /// - 초기 30개(배열) 또는 단건(객체)이 와도 항상 List로 전달
  void Function(List<ChatMessage> messages)? onChatMessages;

  bool get connected => _client?.connected == true;

  /// 연결: 인스턴스 생성 → 바로 채팅 채널 구독
  Future<void> connect(String streamKey) async {
    // 이미 연결돼 있다면 재사용
    if (_streamKey == streamKey && connected) return;

    // 기존 연결 끊기
    await disconnect();

    _streamKey = streamKey;
    final token = await getAccessToken();

    _client = StompClient(
      config: StompConfig.sockJS(
        url: 'http://192.168.0.133:8080/ws',
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: (frame) => _onConnect(frame, streamKey),
        onWebSocketError: (err) => Logger().d('WS error: $err'),
        onStompError: (frame) => Logger().d('STOMP error: ${frame.body}'),
        onDisconnect: (frame) => Logger().d('WS disconnected'),
        // 필요시 하트비트/재연결 옵션 추가 가능
        // heartbeatIncoming: 10000,
        // heartbeatOutgoing: 10000,
        // reconnectDelay: const Duration(seconds: 3),
      ),
    )..activate();
  }

  void _onConnect(StompFrame frame, String streamKey) {
    Logger().d('WS connected');
    _subscribeChat(streamKey); // 연결 즉시 채팅 구독
  }

  void _subscribeChat(String streamKey) {
    if (!connected || _sub != null) return;

    final destination = '/sub/streams/$streamKey/chats';
    // subscribe() : 구독 시작 + 나중에 해제할 수 있는 함수(StompUnsubscribe _sub)를 돌려줌
    _sub = _client!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        final body = frame.body;
        if (body == null || onChatMessages == null) return;

        try {
          // JSON 문자열이 배열 → List<dynamic>으로 변환
          // JSON 문자열이 객체 → Map<String, dynamic>으로 변환
          final decoded = jsonDecode(body);
          Logger().d("서버에서 받은 ChatMessage decoded: $decoded");
          // 배열인 경우
          if (decoded is List) {
            final list = decoded.cast<Map>().map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e))).toList();

            //변환된 List<ChatMessage>를 콜백으로 넘겨줌.
            // UI단에서는 이 콜백을 받아서 Riverpod 상태 갱신 등 처리.
            onChatMessages!.call(list);
          }
          // 객체인 경우
          else if (decoded is Map) {
            onChatMessages!.call(
              [ChatMessage.fromMap(Map<String, dynamic>.from(decoded))],
            );
          }
        } catch (e) {
          Logger().d('chat 파싱 오류: $e');
        }
      },
    );

    Logger().d('채팅방 구독 완료: $destination');
  }

  /// 채팅 전송 (배포): /pub/streams/{streamKey}/chats
  void sendChat(String content) {
    if (!connected || _streamKey == null) return;
    final destination = '/pub/streams/${_streamKey!}/chats';
    _client!.send(
      destination: destination,
      body: jsonEncode({"content": content}),
    );
  }

  /// 채팅 참가 이벤트 전송: /pub/streams/{streamKey}/join
  void sendJoin() {
    if (!connected || _streamKey == null) return;
    _client!.send(destination: '/pub/streams/${_streamKey!}/join');
  }

  /// 연결 종료 (채팅 구독 해제 → 비활성화 → 상태 초기화)
  Future<void> disconnect() async {
    try {
      // 1. 구독 해제
      if (_sub != null) {
        try {
          _sub!.call(); // 구독 해제
        } catch (_) {}
        _sub = null; // 초기화
      }

      // 2. STOMP 종료
      if (_client != null) {
        try {
          _client?.deactivate();
        } catch (_) {}
      }
    } finally {
      // 3. 내부 상태 초기화
      _client = null;
      _streamKey = null;
      // 콜백 참조도 끊어 메모리 누수 방지
      onChatMessages = null;
    }
  }

  /// 리소스 정리 (앱 종료 시)
  Future<void> dispose() async {
    await disconnect();
  }
}
