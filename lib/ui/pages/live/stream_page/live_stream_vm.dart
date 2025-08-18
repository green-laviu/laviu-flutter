import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/data/repository/live_stream_repository.dart';
import 'package:laviu_flutter/main.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/live_stream_page.dart';
import 'package:logger/logger.dart';

final liveStreamProvider =
    AutoDisposeNotifierProvider<LiveStreamVM, LiveStreamModel?>(() {
      return LiveStreamVM();
    });

class LiveStreamVM extends AutoDisposeNotifier<LiveStreamModel?> {
  final mContext = navigatorKey.currentContext!;

  @override
  LiveStreamModel? build() {
    ref.onDispose(() {
      Logger().d("LiveStreamVM 파괴됨");
    });

    return null;
  }

  Future<void> start(String title, List<String> hashtagList) async {
    Logger().d("생방송 시작하기 버튼 클릭 : $title, $hashtagList");

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

    // TODO: rtmp 서버로 송출 요청

    Navigator.pushReplacement(
      mContext,
      MaterialPageRoute(builder: (_) => LiveStreamPage()),
    );
  }
}

class LiveStreamModel {
  LiveStream liveStream;

  LiveStreamModel(this.liveStream);

  LiveStreamModel.fromMap(Map<String, dynamic> data)
    : liveStream = LiveStream.fromJson(data);

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
