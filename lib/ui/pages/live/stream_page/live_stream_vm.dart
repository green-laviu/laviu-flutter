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
}

class LiveStreamModel {
  LiveStream liveStream;

  LiveStreamModel(this.liveStream);

  LiveStreamModel.fromMap(Map<String, dynamic> data) : liveStream = LiveStream.fromJson(data);

  LiveStreamModel copyWith({
    LiveStream? liveStream,
  }) {
    return LiveStreamModel(liveStream ?? this.liveStream);
  }

  @override
  String toString() {
    return 'LiveStreamModel(post: $liveStream)';
  }
}
