import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/gvm/rtmp_publisher_gvm.dart';
import 'package:laviu_flutter/data/model/live_stream.dart';
import 'package:laviu_flutter/data/repository/live_stream_repository.dart';
import 'package:laviu_flutter/main.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/live_stream_page.dart';
import 'package:logger/logger.dart';

final liveStreamProvider = NotifierProvider<LiveStreamGVM, LiveStreamModel?>(() {
  return LiveStreamGVM();
});

class LiveStreamGVM extends Notifier<LiveStreamModel?> {
  final mContext = navigatorKey.currentContext!;

  @override
  LiveStreamModel? build() {
    return null;
  }

  Future<void> start(String title, List<String> hashtagList) async {
    Logger().d("(1) 생방송 시작 버튼 클릭: start() 호출됨 → title=$title, hashtagList=$hashtagList");

    final data = {
      "title": title,
      "hashtagList": hashtagList,
    };

    Logger().d("(2) LiveStreamRepository.start 호출");
    Map<String, dynamic> body = await LiveStreamRepository().start(data);
    Logger().d("(3) Repository 응답 수신: $body");

    if (body["status"] != 200) {
      Logger().e("(999) start 실패: status=${body["status"]}, msg=${body["msg"]}");
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("생방송 시작하기 실패 : ${body["msg"]}")),
      );
      return;
    }

    Logger().d("(4) LiveStreamModel.fromMap으로 state 갱신");
    state = LiveStreamModel.fromMap(body["data"]);
    Logger().d("(5) state 변경 완료: $state");

    // TODO: rtmp 서버로 송출 요청
    final streamKey = state!.liveStream.streamKey;
    Logger().d("(6) startStreaming 호출 준비 → streamKey=$streamKey");
    await ref.read(rtmpPublisherProvider.notifier).startStreaming(streamKey: streamKey);

    Logger().d("(7) start() 정상 완료");

    Navigator.of(mContext).pushReplacement(
      MaterialPageRoute(builder: (_) => const LiveStreamPage()),
    );
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
