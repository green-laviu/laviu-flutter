import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/participant.dart';
import 'package:laviu_flutter/data/repository/web_socket_repository.dart';
import 'package:laviu_flutter/main.dart';
import 'package:logger/logger.dart';

final participantListProvider = AutoDisposeNotifierProvider.family<ParticipantListVM, ParticipantListModel?, String>(
  () {
    return ParticipantListVM();
  },
);

class ParticipantListVM extends AutoDisposeFamilyNotifier<ParticipantListModel?, String> {
  final mContext = navigatorKey.currentContext!;

  late final WebSocketRepository _webSocketRepository;

  @override
  ParticipantListModel? build(String streamKey) {
    _webSocketRepository = WebSocketRepository();

    // 콜백 등록 (호출 X)
    _webSocketRepository.onParticipants = (List<Participant> participantList) {
      _appendParticipants(participantList);
    };

    init(streamKey);

    ref.onDispose(() async {
      Logger().d("ChatListVM 파괴됨");
      _webSocketRepository.unsubscribeParticipants();
      _webSocketRepository.onParticipants = null;
    });

    return null;
  }

  Future<void> init(String streamKey) async {
    if (!_webSocketRepository.connected) {
      await _webSocketRepository.connect(streamKey);
    }
    _webSocketRepository.subscribeParticipants(streamKey);
  }

  void _appendParticipants(List<Participant> incoming) {
    if (incoming.isEmpty) return;

    final existing = state!.participantList;
    final byId = {for (final p in existing) p.userId: p};

    for (final p in incoming) {
      byId[p.userId] = p; // 최신으로 교체
    }

    final next = byId.values.toList()..sort((a, b) => a.connectedAt.compareTo(b.connectedAt));

    state = state!.copyWith(participantList: next);
  }
}

class ParticipantListModel {
  List<Participant> participantList;

  ParticipantListModel(this.participantList);

  ParticipantListModel.fromMap(Map<String, dynamic> data)
    : participantList = (data['participantList'] as List).map((e) => Participant.fromMap(e)).toList();

  ParticipantListModel.fromList(List<dynamic> data)
    : participantList = data.map((e) => Participant.fromMap(Map<String, dynamic>.from(e))).toList();

  ParticipantListModel copyWith({
    List<Participant>? participantList,
  }) {
    return ParticipantListModel(
      participantList ?? this.participantList,
    );
  }

  @override
  String toString() {
    return 'ParticipantListModel{participantList: $participantList}';
  }
}
