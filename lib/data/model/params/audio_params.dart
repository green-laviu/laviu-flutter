import 'package:apivideo_live_stream/apivideo_live_stream.dart';

class AudioParams {
  final int bitrate;
  final int sampleRate;
  final Channel channel;
  final bool enableEchoCanceler;
  final bool enableNoiseSuppressor;

  const AudioParams({
    this.bitrate = 128000,
    this.sampleRate = 44100,
    this.channel = Channel.stereo,
    this.enableEchoCanceler = true,
    this.enableNoiseSuppressor = true,
  });
}
