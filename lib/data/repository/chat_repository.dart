import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:laviu_flutter/_core/utils/m_device.dart';
import 'package:laviu_flutter/_core/utils/m_http.dart';
import 'package:laviu_flutter/data/model/chat_message.dart';
import 'package:logger/logger.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRepository {
  StompClient? _client;
  StompUnsubscribe? _sub;
  String? _streamKey;

  // 서버 주소
  final baseUrl = dotenv.env['BASE_URL']!;

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
        url: '$baseUrl/ws',
        stompConnectHeaders: {'Authorization': '$token'},
        webSocketConnectHeaders: {'Authorization': '$token'},
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

  Future<Map<String, dynamic>> getChatList(int streamId) async {
    Response response = await dio.get("/s/api/v1/streams/$streamId/chats");
    final responseBody = response.data;
    // final responseBody = {
    //   "status": 200,
    //   "msg": "성공",
    //   "data": [
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "오늘 저녁 뭐 드셨어요?",
    //       "timestamp": "2025-08-21T16:32:13",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "김치찌개 먹었어요.",
    //       "timestamp": "2025-08-21T16:32:14",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "오 맛있겠네요. 저도 그거 좋아해요.",
    //       "timestamp": "2025-08-21T16:32:15",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "다음에 같이 먹어요.",
    //       "timestamp": "2025-08-21T16:32:16",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "네 콜! 한판 하시고 밥 먹으러 가시죠",
    //       "timestamp": "2025-08-21T16:32:17",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "네 좋죠!",
    //       "timestamp": "2025-08-21T16:32:18",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "오 진짜로요?",
    //       "timestamp": "2025-08-21T16:32:19",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "네! 당연하죠.",
    //       "timestamp": "2025-08-21T16:32:20",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "와 진짜 감사합니다.",
    //       "timestamp": "2025-08-21T16:32:21",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "별말씀을요.",
    //       "timestamp": "2025-08-21T16:32:22",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "오늘 방송 몇 시까지 하세요?",
    //       "timestamp": "2025-08-21T16:32:23",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "밤 11시까지 할 것 같아요.",
    //       "timestamp": "2025-08-21T16:32:24",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "네 알겠습니다. 좀만 더 보고 잘게요.",
    //       "timestamp": "2025-08-21T16:32:25",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "네 푹 주무세요.",
    //       "timestamp": "2025-08-21T16:32:26",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "방송 켜주셔서 감사합니다.",
    //       "timestamp": "2025-08-21T16:32:27",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "와주셔서 제가 더 감사하죠.",
    //       "timestamp": "2025-08-21T16:32:28",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "내일도 방송하시나요?",
    //       "timestamp": "2025-08-21T16:32:29",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "네 내일도 합니다.",
    //       "timestamp": "2025-08-21T16:32:30",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "네 내일도 올게요.",
    //       "timestamp": "2025-08-21T16:32:31",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "네 내일 뵈요.",
    //       "timestamp": "2025-08-21T16:32:32",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "채팅 딜레이 없네요. 신기하다!",
    //       "timestamp": "2025-08-21T16:32:33",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "네, 서버를 최적화했어요.",
    //       "timestamp": "2025-08-21T16:32:34",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "대단하시네요. 직접 하신 건가요?",
    //       "timestamp": "2025-08-21T16:32:35",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "네, 혼자서 전부 개발했습니다.",
    //       "timestamp": "2025-08-21T16:32:36",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "와 진짜 존경스럽습니다.",
    //       "timestamp": "2025-08-21T16:32:37",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "과찬이세요.",
    //       "timestamp": "2025-08-21T16:32:38",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "앞으로도 자주 올게요.",
    //       "timestamp": "2025-08-21T16:32:39",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "네 언제든지 환영합니다.",
    //       "timestamp": "2025-08-21T16:32:40",
    //     },
    //     {
    //       "authorId": 1,
    //       "authorNickname": "ssar",
    //       "emailId": "ssar",
    //       "isStreamer": true,
    //       "content": "오늘 너무 즐거웠어요.",
    //       "timestamp": "2025-08-21T16:32:41",
    //     },
    //     {
    //       "authorId": 3,
    //       "authorNickname": "love",
    //       "emailId": "love",
    //       "isStreamer": false,
    //       "content": "저도 정말 즐거웠습니다.",
    //       "timestamp": "2025-08-21T16:32:42",
    //     },
    //   ],
    // };
    Logger().d('ChatRepository의 getChatList: ${responseBody}');
    return responseBody;
  }
}
