class LiveStream {
  final int streamId;
  final String streamKey;
  final int streamerId;
  final String streamerName;
  final String streamerProfileImageUrl;
  final String title;
  final int viewerCount;
  final String streamStatus;
  final String thumbnailUrl;
  final List<String> hashtags;

  LiveStream({
    required this.streamId,
    required this.streamKey,
    required this.streamerId,
    required this.streamerName,
    required this.streamerProfileImageUrl,
    required this.title,
    required this.viewerCount,
    required this.streamStatus,
    required this.thumbnailUrl,
    required this.hashtags,
  });

  factory LiveStream.fromJson(Map<String, dynamic> j) => LiveStream(
    streamId: j['streamId'] as int,
    streamKey: j['streamKey'] as String,
    streamerId: j['streamerId'] as int,
    streamerName: j['streamerName'] as String,
    streamerProfileImageUrl: j['streamerProfileImageUrl'] as String,
    title: j['title'] as String,
    viewerCount: j['viewerCount'] as int,
    streamStatus: j['streamStatus'] as String,
    thumbnailUrl: j['thumbnailUrl'] as String,
    hashtags: List<String>.from(j['hashtags'] as List),
  );
}
