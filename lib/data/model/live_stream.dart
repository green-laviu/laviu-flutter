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

    if (map['hashtagList'] is List) {
      parsedHashtags = (map['hashtagList'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Hashtag.fromMap(e))
          .toList();
    } else if (map['hashtags'] is List) {
      parsedHashtags = (map['hashtags'] as List)
          .whereType<String>()
          .map((name) => Hashtag(hashtagName: name))
          .toList();
    } else {
      parsedHashtags = const [];
    }

    // 서버 status or 기존 streamStatus
    final statusValue = (map['streamStatus'] ?? map['status']) as String?;

    // streamer 객체 처리
    final streamer = map['streamer'] as Map<String, dynamic>?;

    return LiveStream(
      streamId: map['streamId'] as int,
      streamKey: map['streamKey'] as String,
      title: map['title'] as String,
      streamStatus: StreamStatus.fromValue(statusValue),
      hashtagList: parsedHashtags,
      // 평탄화
      streamerId: streamer?['userId'] as int? ?? map['streamerId'] as int?,
      streamerName:
          streamer?['nickname'] as String? ?? map['streamerName'] as String?,
      streamerProfileImageUrl:
          streamer?['profileImageUrl'] as String? ??
          map['streamerProfileImageUrl'] as String?,
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
