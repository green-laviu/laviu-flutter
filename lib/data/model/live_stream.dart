import 'package:laviu_flutter/data/model/enums/stream_status.dart';
import 'package:laviu_flutter/data/model/hashtag.dart';

class LiveStream {
  final int streamId;
  final String streamKey;
  final int? streamerId;
  final String? streamerName;
  final String? streamerProfileImageUrl;
  final String title;
  final int? viewerCount;
  final StreamStatus streamStatus;
  final String? thumbnailUrl;
  final List<Hashtag> hashtagList;

  // 기존 해시태그 String 리스트 호환용 getter
  List<String> get hashtags => hashtagList.map((e) => e.hashtagName).toList();

  LiveStream({
    required this.streamId,
    required this.streamKey,
    required this.title,
    required this.streamStatus,
    this.hashtagList = const [],
    this.streamerId,
    this.streamerName,
    this.streamerProfileImageUrl,
    this.viewerCount,
    this.thumbnailUrl,
  });

  factory LiveStream.fromJson(Map<String, dynamic> map) {
    final List<Hashtag> parsedHashtags;

    // List<Hashtag> hashtagList
    if (map['hashtagList'] is List) {
      parsedHashtags = (map['hashtagList'] as List)
          .whereType<Map<String, dynamic>>() // map인 애들만 추출
          .map((e) => Hashtag.fromMap(e)) // map → Hashtag(클래스) 변환
          .toList();
    } // List<String> hashtags
    else if (map['hashtags'] is List) {
      parsedHashtags = (map['hashtags'] as List)
          .whereType<String>()
          .map((name) => Hashtag(hashtagName: name)) // id 없이 생성
          .toList();
    } else {
      parsedHashtags = const [];
    }

    // 서버에서 받아온 stream status 값
    final statusValue = (map['streamStatus'] ?? map['status']) as String?;

    return LiveStream(
      streamId: map['streamId'] as int,
      streamKey: map['streamKey'] as String,
      title: map['title'] as String,
      streamStatus: StreamStatus.fromValue(statusValue),
      hashtagList: parsedHashtags,
      streamerId: map['streamerId'] as int?,
      streamerName: map['streamerName'] as String?,
      streamerProfileImageUrl: map['streamerProfileImageUrl'] as String?,
      viewerCount: map['viewerCount'] as int?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streamId': streamId,
      'streamKey': streamKey,
      'title': title,
      'status': streamStatus.value,
      'hashtagList': hashtagList.map((e) => e.toMap()).toList(),
      'streamerId': streamerId,
      'streamerName': streamerName,
      'streamerProfileImageUrl': streamerProfileImageUrl,
      'viewerCount': viewerCount,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}
