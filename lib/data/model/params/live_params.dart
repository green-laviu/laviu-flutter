import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LiveParams {
  // 비디오
  int videoBitrate = 5_000_000; // bps
  Resolution videoResolution = Resolution.RESOLUTION_1080;
  int videoFps = 30;

  // 커스텀 비트레이트 사용
  VideoConfig get videoConfig => VideoConfig(
    bitrate: videoBitrate,
    resolution: videoResolution,
    fps: videoFps,
  );

  // 또는 해상도에 맞는 기본 비트레이트 자동 설정을 쓰고 싶다면:
  // VideoConfig get videoConfig => VideoConfig.withDefaultBitrate(
  //   resolution: videoResolution,
  //   fps: videoFps,
  // );

  // 오디오
  int audioBitrate = 128000;
  Channel audioChannel = Channel.stereo;
  SampleRate audioSampleRate = SampleRate.kHz_44_1; // ← int 대신 enum
  bool audioEnableEchoCanceler = true;
  bool audioEnableNoiseSuppressor = true;

  AudioConfig get audioConfig => AudioConfig(
    bitrate: audioBitrate,
    channel: audioChannel,
    sampleRate: audioSampleRate,
    enableEchoCanceler: audioEnableEchoCanceler,
    enableNoiseSuppressor: audioEnableNoiseSuppressor,
  );

  // RTMP
  final rtmpUrl = dotenv.env['RTMP_BASE_URL']!;
}
