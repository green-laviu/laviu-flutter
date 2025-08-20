import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/params/params.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/live_preview_fm.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/live_stream_vm.dart';
import 'package:laviu_flutter/ui/pages/live/streaming_page/widgets/live_streaming_preview_overlay.dart';
import 'package:laviu_flutter/ui/pages/live/streaming_page/widgets/live_streaming_stream_overlay.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LiveStreamingPage extends ConsumerStatefulWidget {
  const LiveStreamingPage({super.key});
  @override
  ConsumerState<LiveStreamingPage> createState() => _LiveStreamingPageState();
}

class _LiveStreamingPageState extends ConsumerState<LiveStreamingPage> with WidgetsBindingObserver {
  final formKey = GlobalKey<FormState>(); // preview 전용
  final _msgCtrl = TextEditingController(); // stream 전용
  final _scrollCtrl = ScrollController(); // stream 전용

  late final ApiVideoLiveStreamController _streamCtrl;
  late final ApiVideoLiveStreamEventsListener _listener;
  final params = Params();

  bool _initialized = false;
  bool _isStreaming = false;
  bool _isMuted = false;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WakelockPlus.enable(); // 화면 꺼짐 방지

    _streamCtrl = ApiVideoLiveStreamController(
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

    _streamCtrl.addEventsListener(_listener);

    _streamCtrl
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _initialized = true);
        })
        .catchError((e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    _streamCtrl.removeEventsListener(_listener); // ← 등록했던 인스턴스 전달
    _streamCtrl.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> startStreaming() async {
    final model = ref.read(liveStreamProvider);
    if (model == null) {
      throw Exception("LiveStreamModel 없음: start() 먼저 호출 필요"); // -> 전역 에러 핸들러로
    }

    // 토큰 불러오기
    // final accessToken = await getAccessToken();
    // if (accessToken == null) {
    //   throw Exception("액세스 토큰 없음");
    // }
    // final accessToken =
    //     "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJsYXZpdSIsInJvbGVzIjoiVVNFUiIsIm5pY2tuYW1lIjoidGVzdFN0cmVhbWVyIiwiaWQiOjUsImV4cCI6MTc1NjI2NjEzMywiZW1haWwiOiJ0ZXN0U3RyZWFtZXJAbmF0ZS5jb20ifQ.Buvlkcat0_GSYQunSuAYpoO94Rf5IOyZj1sLrYKKTox_iwaDLWzLYZp1nowvV8m2_W_FT7QCmWgtvHdltcIlkw";
    //
    // // 최종 streamKey 구성
    // final finalKey = "${model.liveStream.streamKey}?token=$accessToken";
    // Logger().d("finalKey : $finalKey");
    //
    // // 송출 시작
    // await _streamCtrl.startStreaming(
    //   url: params.rtmpUrl,
    //   streamKey: finalKey,
    // );
    await _streamCtrl.startStreaming(
      url: params.rtmpUrl,
      streamKey: model.liveStream.streamKey,
    );
  }

  Future<void> stopStreaming() async => _streamCtrl.stopStreaming();

  // 음소거 토글
  Future<void> toggleMute() async {
    if (!_initialized) return;
    await _streamCtrl.toggleMute();
    if (!mounted) return;
    setState(() => _isMuted = !_isMuted);
  }

  // 전후면 카메라 전환
  Future<void> switchCamera() async {
    if (!_initialized) return;
    await _streamCtrl.switchCamera();
    if (!mounted) return;
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  @override
  Widget build(BuildContext context) {
    LiveStreamVM vm = ref.read(liveStreamProvider.notifier);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus(); // 빈영역 터치 -> 키보드 내려감
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: ApiVideoCameraPreview(
                controller: _streamCtrl,
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: IndexedStack(
                index: _isStreaming ? 1 : 0,
                children: [
                  LiveStreamingPreviewOverlay(
                    formKey: formKey,
                    onStart: () async {
                      // 1. 검증
                      if (!formKey.currentState!.validate()) return;

                      // 2. 프리뷰 → 스트림 오버레이 전환
                      if (!mounted) return;
                      setState(() => _isStreaming = true);

                      try {
                        // 3. 서버에 방송 생성 요청 (streamKey 수령)
                        final previewModel = ref.read(livePreviewProvider); // 최신 값
                        await vm.start(previewModel.title, previewModel.hashtagList);

                        // 4. state 세팅 확인
                        final streamModel = ref.read(liveStreamProvider);
                        if (streamModel == null) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('방송 생성(start) 실패')),
                          );
                          setState(() => _isStreaming = false); // 실패 시 롤백
                          return;
                        }

                        // 5. RTMP 송출 시작
                        await startStreaming();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('방송 시작(startStreaming) 실패: $e')),
                        );
                        setState(() => _isStreaming = false); // 실패 시 롤백
                      }
                    },
                    onClose: () => Navigator.pop(context),
                    onToggleMute: _initialized ? toggleMute : null,
                    onSwitchCamera: _initialized ? switchCamera : null,
                    isMuted: _isMuted,
                    isFrontCamera: _isFrontCamera,
                  ),
                  LiveStreamingStreamOverlay(
                    scrollCtrl: _scrollCtrl,
                    msgCtrl: _msgCtrl,
                    onStop: () async {
                      await stopStreaming();
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    onToggleMute: _initialized ? toggleMute : null,
                    onSwitchCamera: _initialized ? switchCamera : null,
                    isMuted: _isMuted,
                    isFrontCamera: _isFrontCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
