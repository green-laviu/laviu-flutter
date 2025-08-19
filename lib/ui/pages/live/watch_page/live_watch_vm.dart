import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/model/chat_message.dart';
import '../../../../data/repository/chat_repository.dart';
import '../../../../data/repository/chat_providers.dart';

class ChatMessagesState {
  final List<ChatMessage> items;
  final bool loading;
  final String? error;

  const ChatMessagesState({
    required this.items,
    this.loading = true,
    this.error,
  });

  ChatMessagesState copyWith({
    List<ChatMessage>? items,
    bool? loading,
    String? error,
  }) {
    return ChatMessagesState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  ChatMessagesNotifier(this.ref, this.args, {this.maxBuffer = 200})
    : super(const ChatMessagesState(items: [], loading: true));

  final Ref ref;
  final (String wsUrl, String jwt, String streamKey) args;
  final int maxBuffer;

  StreamSubscription<ChatMessage>? _sub;
  bool _started = false;

  ChatRepository get _repo => ref.read(chatRepositoryProvider(args));

  void start() {
    if (_started) return;
    _started = true;

    _repo.connect();
    _repo.join();

    if (_repo.isMock) {
      // ✅ 초기 배치 로드 (30개)
      final batch = _repo.mockGetLatestBatch(limit: 30); // 최신→오래된
      state = state.copyWith(items: batch, loading: false, error: null);
      // mock에선 실시간 스트림 구독 불필요
      ref.onDispose(() async => await _repo.disconnect());
      return;
    }

    // ✅ 실서버: 실시간 단건 스트림 구독 (배치는 서버 규약에 맞춰 별도 처리)
    _sub = _repo.chatStream.listen(
      (m) {
        final next = [m, ...state.items];
        if (next.length > maxBuffer) next.removeRange(maxBuffer, next.length);
        state = state.copyWith(items: next, loading: false, error: null);
      },
      onError: (e, st) {
        state = state.copyWith(loading: false, error: '채팅 수신 오류');
      },
    );

    ref.onDispose(() async {
      await _sub?.cancel();
      await _repo.disconnect();
    });
  }

  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    _repo.sendChat(text);

    if (_repo.isMock) {
      // 내 메시지를 반영한 최신 30개 배치로 교체
      final batch = _repo.mockGetLatestBatch(limit: 30);
      state = state.copyWith(items: batch, loading: false, error: null);
    }
  }
}

// family provider: (wsUrl, jwt, streamKey)로 각각 다른 스트림 방을 관리
final chatMessagesProvider =
    StateNotifierProvider.family<
      ChatMessagesNotifier,
      ChatMessagesState,
      (String wsUrl, String jwt, String streamKey)
    >((ref, args) {
      final n = ChatMessagesNotifier(ref, args)..start();
      return n;
    });
