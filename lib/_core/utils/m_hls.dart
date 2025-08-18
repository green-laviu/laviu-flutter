// lib/_core/utils/m_hls.dart
class MHlsUrl {
  static String fixed({
    required String origin,
    required String streamKey,
    required String quality, // '1080p' | '720p' | '480p'
  }) => '$origin/hls/${streamKey}_$quality/index.m3u8';
}

enum LiveQuality { p1080, p720, p480 }

extension LiveQualityX on LiveQuality {
  String get label {
    switch (this) {
      case LiveQuality.p1080:
        return '1080p';
      case LiveQuality.p720:
        return '720p';
      case LiveQuality.p480:
        return '480p';
    }
  }

  // URL에 쓰는 슬러그(지금은 label과 동일)
  String get slug => label;
}
