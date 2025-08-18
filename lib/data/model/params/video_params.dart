import 'package:laviu_flutter/data/model/enums/fps_preset.dart';
import 'package:laviu_flutter/data/model/enums/quality_preset.dart';

class VideoParams {
  final QualityPreset preset;
  final FpsPreset fps;
  final int bitrate; // bps
  const VideoParams({
    required this.preset,
    required this.fps,
    required this.bitrate,
  });

  VideoParams copyWith({QualityPreset? preset, FpsPreset? fps, int? bitrate}) =>
      VideoParams(
        preset: preset ?? this.preset,
        fps: fps ?? this.fps,
        bitrate: bitrate ?? this.bitrate,
      );
}
