import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/chat_message.dart';
import 'package:laviu_flutter/data/repository/web_socket_repository.dart';
import 'package:laviu_flutter/main.dart';
import 'package:logger/logger.dart';

// 창고 관리자
final chatListProvider = AutoDisposeNotifierProvider.family<ChatListVM, ChatListModel?, String>(() {
  return ChatListVM();
});

// 창고
class ChatListVM extends AutoDisposeFamilyNotifier<ChatListModel?, String> {
  final mContext = navigatorKey.currentContext!;

  late final WebSocketRepository _webSocketRepository;

  @override
  ChatListModel? build(String streamKey) {
    _webSocketRepository = WebSocketRepository();

    // 콜백 등록 (호출 X)
    _webSocketRepository.onChatMessages = (List<ChatMessage> messages) {
      appendNewMessages(messages);
    };

    init(streamKey);

    ref.onDispose(() async {
      Logger().d("ChatListVM 파괴됨");
      await _webSocketRepository.dispose();
    });

    return null;
  }

  Future<void> init(String streamKey) async {
    await _webSocketRepository.connect(streamKey);
  }

  void appendNewMessages(List<ChatMessage> incoming) {
    if (incoming.isEmpty) return;

    if (state == null) {
      final sorted = [...incoming]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      state = ChatListModel(sorted);
      return;
    }

    final existing = state!.chatMessageList;
    final existingKeys = existing.map((m) => m.dedupKey).toSet();
    final onlyNew = incoming.where((m) => !existingKeys.contains(m.dedupKey));

    if (onlyNew.isEmpty) return;

    final next = [...existing, ...onlyNew]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    state = state!.copyWith(chatMessageList: next);
  }

  Future<void> sendChat(String content) async {
    _webSocketRepository.sendChat(content);

    _webSocketRepository.onChatMessages = (List<ChatMessage> messages) {
      appendNewMessages(messages);
    };
  }
}

// 창고 데이터 타입
class ChatListModel {
  List<ChatMessage> chatMessageList;

  ChatListModel(this.chatMessageList);

  ChatListModel.fromMap(Map<String, dynamic> data)
    : chatMessageList = (data['chatMessageList'] as List).map((e) => ChatMessage.fromMap(e)).toList();

  ChatListModel.fromList(List<dynamic> data)
    : chatMessageList = data.map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e))).toList();

  ChatListModel copyWith({
    List<ChatMessage>? chatMessageList,
  }) {
    return ChatListModel(
      chatMessageList ?? this.chatMessageList,
    );
  }

  @override
  String toString() {
    return 'ChatListModel{chatMessageList: $chatMessageList}';
  }
}
