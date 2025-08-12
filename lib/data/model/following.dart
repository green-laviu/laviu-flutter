import 'package:laviu_flutter/data/model/live_stream.dart';

class FollowingChannel {
  final int streamerId;
  final String streamerName;
  final String streamerProfileImageUrl;
  final String streamStatus; // LIVE / ENDED

  FollowingChannel({
    required this.streamerId,
    required this.streamerName,
    required this.streamerProfileImageUrl,
    required this.streamStatus,
  });

  factory FollowingChannel.fromJson(Map<String, dynamic> j) => FollowingChannel(
    streamerId: j['streamerId'] as int,
    streamerName: j['streamerName'] as String,
    streamerProfileImageUrl: j['streamerProfileImageUrl'] as String,
    streamStatus: j['streamStatus'] as String,
  );
}

class FollowingFeed {
  final List<FollowingChannel> channels;
  final List<LiveStream> lives;

  FollowingFeed({required this.channels, required this.lives});

  factory FollowingFeed.fromJson(Map<String, dynamic> j) => FollowingFeed(
    channels: (j['followingChannels'] as List)
        .map((e) => FollowingChannel.fromJson(e))
        .toList(),
    lives: (j['followingLiveStreams'] as List)
        .map((e) => LiveStream.fromJson(e))
        .toList(),
  );
}
