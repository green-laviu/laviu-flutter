import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/utils/m_device.dart';
import 'package:laviu_flutter/data/gvm/session_gvm.dart';
import 'package:laviu_flutter/data/model/chat_message.dart';
import 'package:laviu_flutter/data/repository/chat_repository.dart';
import 'package:laviu_flutter/main.dart';
import 'package:logger/logger.dart';

final chatListProvider = AutoDisposeNotifierProvider.family<ChatListVM, ChatListModel?, (String, int)>(() {
  return ChatListVM();
});

class ChatListVM extends AutoDisposeFamilyNotifier<ChatListModel?, (String, int)> {
  final mContext = navigatorKey.currentContext!;

  late final ChatRepository _chatRepository;

  @override
  ChatListModel? build((String streamKey, int streamId) args) {
    final streamKey = args.$1;
    final streamId = args.$2;

    _chatRepository = ChatRepository();

    // 콜백 등록 (호출 X)
    _chatRepository.onChatMessages = (List<ChatMessage> messages) {
      appendNewMessages(messages);
    };

    init(streamKey, streamId);

    ref.onDispose(() async {
      Logger().d("ChatListVM 파괴됨");
      await _chatRepository.dispose();
    });

    return null;
  }

  Future<void> init(String streamKey, int streamId) async {
    // 1) 세션에서 토큰 우선 사용(메모리), 없으면 저장소에서 fallback
    final session = ref.read(sessionProvider);
    String? token = session.user?.accessToken;
    token ??= await getAccessToken();

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        const SnackBar(content: Text("인증 토큰이 없습니다. 다시 로그인 해주세요.")),
      );
      return;
    }

    await _chatRepository.connect(streamKey, token);

    _chatRepository.onChatMessages = (List<ChatMessage> messages) {
      appendNewMessages(messages);
    };

    Map<String, dynamic> body = await _chatRepository.getChatList(streamId);

    if (body["status"] != 200) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("채팅 목록 조회 실패 : ${body["msg"]}")),
      );
      return;
    }
    final data = (body['data'] as List).map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e))).toList();

    appendNewMessages(data);
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
    _chatRepository.sendChat(content);

    _chatRepository.onChatMessages = (List<ChatMessage> messages) {
      appendNewMessages(messages);
    };
  }
}

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
