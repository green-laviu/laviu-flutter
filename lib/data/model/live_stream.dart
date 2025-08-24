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
  final bool? isLive;

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
    this.isLive,
  });

  factory LiveStream.fromJson(Map<String, dynamic> map) {
    // v2 스키마: streamer{ userId, nickname, profileImageUrl, ... }
    final streamer = (map['streamer'] is Map)
        ? Map<String, dynamic>.from(map['streamer'] as Map)
        : null;

    // List<Hashtag> hashtagList 또는 List<String> hashtags 모두 지원
    final List<Hashtag> parsedHashtags;
    if (map['hashtagList'] is List) {
      parsedHashtags = (map['hashtagList'] as List)
          .whereType<Map>()
          .map((e) => Hashtag.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } else if (map['hashtags'] is List) {
      parsedHashtags = (map['hashtags'] as List)
          .whereType<String>()
          .map((name) => Hashtag(hashtagName: name))
          .toList();
    } else {
      parsedHashtags = const [];
    }

    // 상태 키: streamStatus 또는 status
    final statusValue = (map['streamStatus'] ?? map['status']) as String?;

    return LiveStream(
      streamId: (map['streamId'] as num).toInt(),
      streamKey: (map['streamKey'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      streamStatus: StreamStatus.fromValue(statusValue),
      hashtagList: parsedHashtags,

      // 상위 키 우선, 없으면 streamer{}에서 보강
      streamerId: (map['streamerId'] ?? streamer?['userId']) is num
          ? (map['streamerId'] ?? streamer?['userId'] as num).toInt()
          : null,
      streamerName: (map['streamerName'] ?? streamer?['nickname']) as String?,
      streamerProfileImageUrl:
          (map['streamerProfileImageUrl'] ?? streamer?['profileImageUrl'])
              as String?,

      viewerCount: (map['viewerCount'] is num)
          ? (map['viewerCount'] as num).toInt()
          : null,

      // 썸네일 키 변경 가능성 대비
      thumbnailUrl:
          (map['thumbnailUrl'] ?? map['thumbUrl'] ?? map['imageUrl'])
              as String?,
      isLive: map['isLive'],
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
      'isLive': isLive,
    };
  }
}
