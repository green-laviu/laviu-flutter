import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/data/model/params/params.dart';

class LiveStreamingPage extends StatefulWidget {
  const LiveStreamingPage({super.key});
  @override
  State<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends State<LiveStreamingPage> with WidgetsBindingObserver {
  late final ApiVideoLiveStreamController _controller;
  late final ApiVideoLiveStreamEventsListener _listener;
  final Params params = Params();
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = ApiVideoLiveStreamController(
      initialVideoConfig: params.videoConfig,
      initialAudioConfig: params.audioConfig,
    );

    _listener = ApiVideoLiveStreamEventsListener(
      onConnectionSuccess: () {
        if (!mounted) return;
        setState(() => _isStreaming = true);
      },
      onDisconnection: () {
        if (!mounted) return;
        setState(() => _isStreaming = false);
      },
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        setState(() => _isStreaming = false);
      },
    );

    _controller.addEventsListener(_listener);

    _controller.initialize().catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeEventsListener(_listener); // ← 등록했던 인스턴스 전달
    _controller.dispose();
    super.dispose();
  }

  Future<void> startStreaming() async {
    await _controller.startStreaming(
      url: params.rtmpUrl,
      streamKey: params.streamKey,
    );
  }

  Future<void> stopStreaming() async => _controller.stopStreaming();
  Future<void> switchCamera() async => _controller.switchCamera();
  Future<void> toggleMute() async => _controller.toggleMute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ApiVideoCameraPreview(
              controller: _controller,
              // fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: switchCamera, child: const Text('카메라 전환')),
                ElevatedButton(
                  onPressed: _isStreaming ? stopStreaming : startStreaming,
                  child: Text(_isStreaming ? '중지' : '송출 시작'),
                ),
                ElevatedButton(onPressed: toggleMute, child: const Text('음소거')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
