import 'dart:ui';

import 'package:laviu_flutter/data/model/enums/fps_preset.dart';

enum QualityPreset {
  p480("480", 854, 480),
  p720("720", 1280, 720),
  p1080("1080", 1920, 1080);

  final String label; // UI/서버 전달 값
  final int width;
  final int height;

  const QualityPreset(this.label, this.width, this.height);

  // resolution(해상도)
  Size get resolution => Size(width.toDouble(), height.toDouble());

  // 권장 비트레이트
  int defaultBitrate(FpsPreset fps) {
    switch ((this, fps)) {
      case (QualityPreset.p480, FpsPreset.fps30):
        return 1_200_000;
      case (QualityPreset.p480, FpsPreset.fps60):
        return 1_800_000;
      case (QualityPreset.p720, FpsPreset.fps30):
        return 2_500_000;
      case (QualityPreset.p720, FpsPreset.fps60):
        return 3_500_000;
      case (QualityPreset.p1080, FpsPreset.fps30):
        return 4_500_000;
      case (QualityPreset.p1080, FpsPreset.fps60):
        return 6_000_000;
    }
  }

  @override
  String toString() => label; // "480", "720", "1080"
}
