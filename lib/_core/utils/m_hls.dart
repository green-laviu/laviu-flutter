class MHlsUrl {
  static String master({
    required String origin, // 예: http://host:port
    required String streamKey, // 예: abc123
  }) => '$origin/hls/$streamKey.m3u8';

  static String fixed({
    required String origin,
    required String streamKey,
    required String quality, // '1080p' | '720p' | '480p'
  }) => '$origin/hls/${streamKey}_$quality/index.m3u8';
}

enum LiveQuality { auto, p1080, p720, p480 }

extension LiveQualityX on LiveQuality {
  String get label => switch (this) {
    LiveQuality.auto => 'AUTO',
    LiveQuality.p1080 => '1080p',
    LiveQuality.p720 => '720p',
    LiveQuality.p480 => '480p',
  };
}
