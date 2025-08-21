import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_repository.dart';

const bool kUseChatMock = true; // ✅ 서버 붙기 전엔 true

/// ChatRepository 주입 (args: wsUrl, jwt, streamKey)
final chatRepositoryProvider =
    Provider.family<
      ChatRepository,
      (String wsUrl, String jwt, String streamKey)
    >((ref, args) {
      final (wsUrl, jwt, streamKey) = args;
      final repo = ChatRepository(
        wsUrl: wsUrl,
        jwt: jwt,
        streamKey: streamKey,
        mockMode: kUseChatMock, // ✅
      );
      ref.onDispose(repo.dispose);
      return repo;
    });

/// 연결 상태 스트림 (연결 아이콘/토스트 등에 사용)
final chatConnStateProvider =
    StreamProvider.family<
      ChatConnState,
      (String wsUrl, String jwt, String streamKey)
    >((ref, args) {
      final repo = ref.watch(chatRepositoryProvider(args));
      return repo.connState;
    });
