import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/data/repository/live_stream_repository.dart';
import 'package:laviu_flutter/main.dart';
import 'package:logger/logger.dart';

final liveStreamProvider = NotifierProvider<LiveStreamVM, LiveStreamModel?>(() {
  return LiveStreamVM();
});

class LiveStreamVM extends Notifier<LiveStreamModel?> {
  final mContext = navigatorKey.currentContext!;

  @override
  LiveStreamModel? build() {
    ref.onDispose(() {
      Logger().d("LiveStreamVM 파괴됨");
    });

    return null;
  }

  Future<void> start(String title, List<String> hashtagList) async {
    final data = {
      "title": title,
      "hashtagList": hashtagList,
    };

    Map<String, dynamic> body = await LiveStreamRepository().start(data);

    if (body["status"] != 200) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("생방송 시작하기 실패 : ${body["msg"]}")),
      );
      return;
    }

    state = LiveStreamModel.fromMap(body["data"]);
  }

  Future<void> end(int streamId) async {
    Map<String, dynamic> body = await LiveStreamRepository().end(streamId);

    if (body["status"] != 200) {
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("생방송 종료 실패 : ${body["msg"]}")),
      );
      return;
    }

    state = null;

    Navigator.pop(mContext);
  }

  void setStartedAt(DateTime time) {
    state = state!.copyWith(startedAt: time);
  }
}

class LiveStreamModel {
  final LiveStream liveStream;
  final DateTime? startedAt;

  LiveStreamModel(this.liveStream, this.startedAt);

  LiveStreamModel.fromMap(Map<String, dynamic> data)
    : liveStream = LiveStream.fromJson(data),
      startedAt = data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null;

  LiveStreamModel copyWith({
    LiveStream? liveStream,
    DateTime? startedAt,
  }) {
    return LiveStreamModel(
      liveStream ?? this.liveStream,
      startedAt ?? this.startedAt,
    );
  }
}
