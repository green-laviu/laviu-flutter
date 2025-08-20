import 'dart:async';

import 'package:laviu_flutter/_core/utils/m_device.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatRepository {
  StompClient? _client;
  StompUnsubscribe? _sub;
  String? _streamKey;

  bool get connected => _client?.connected == true;

  /// 연결 + 구독
  Future<void> connect(String streamKey) async {
    // 이미 연결돼 있다면 재사용
    if (_streamKey == streamKey && connected) return;

    // 기존 연결 끊기
    await disconnect();
    _streamKey = streamKey;

    final token = await getAccessToken();

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        stompConnectHeaders: {'Authorization': '$token'},
        webSocketConnectHeaders: {'Authorization': '$token'},
        onConnect: (frame) => _onConnect(frame, streamKey),
        onWebSocketError: (err) => print('WS error: $err'),
        onDisconnect: (frame) => print('WS disconnected'),
        // heartbeatIncoming: 10000,
        // heartbeatOutgoing: 10000,
        // reconnectDelay: Duration(seconds: 3),
      ),
    )..activate();
  }
}
