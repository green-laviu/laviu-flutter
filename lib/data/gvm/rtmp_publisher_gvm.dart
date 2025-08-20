import 'dart:async';

import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/utils/m_device.dart';
import 'package:laviu_flutter/data/model/enums/fps_preset.dart';
import 'package:laviu_flutter/data/model/enums/quality_preset.dart';
import 'package:laviu_flutter/data/model/params/audio_params.dart';
import 'package:laviu_flutter/data/model/params/publisher_status.dart';
import 'package:laviu_flutter/data/model/params/rtmp_server_params.dart';
import 'package:laviu_flutter/data/model/params/video_params.dart';
import 'package:logger/logger.dart';

final rtmpPublisherProvider = NotifierProvider<RtmpPublisherGVM, RtmpPublisherModel>(
  () => RtmpPublisherGVM(),
);

class RtmpPublisherGVM extends Notifier<RtmpPublisherModel> {
  ApiVideoLiveStreamController? _streamCtrl;

  bool _initialized = false; // initialize() 호출했는지
  bool _previewing = false; // startPreview() 중인지 (프리뷰 중복 시작 방지)
  bool _streaming = false; // 방송 중인지 (실제 RTMP 송출 중 여부. 프리뷰 상태 표시 판단에 사용)
  bool _disposed = false; // 이 Notifier가 폐기(dispose)됐는지
  bool _opBusy = false; // 동시에 같은 작업이 겹치지 않게 하는 락
  bool _tearingDown = false; // shutdown() 진행 중인지 (종료 중에는 init/preview 등 재호출을 차단)

  static Completer<void>? _teardownInFlight;

  // controller 외부에서 호출
  ApiVideoLiveStreamController? get controller => _streamCtrl;

  bool get isPreviewVisible => _streamCtrl != null && _previewing && (_streamCtrl?.textureId != null);

  bool get isTearingDown => _tearingDown || _teardownInFlight != null;

  @override
  RtmpPublisherModel build() {
    ref.keepAlive();
    return RtmpPublisherModel.initial();
  }

  // 동시에 같은 작업이 겹치지 않게 함 (더블탭 방지)
  Future<T?> _guard<T>(Future<T> Function() op) async {
    if (_opBusy || _disposed) return null;
    _opBusy = true;
    try {
      return await op();
    } finally {
      _opBusy = false;
    }
  }

  // 1. 진행 중인 teardown이 있으면 끝날 때까지 반드시 대기
  Future<void> _awaitTeardownIfAny() async {
    final t = _teardownInFlight;
    if (t != null) {
      Logger().d('(0) 이전 teardown 대기 중...');
      await t.future;
      Logger().d('(0) 이전 teardown 완료');
    }
  }

  // 2. 이번 호출이 teardown을 시작한다는 표식 세팅
  void _beginTeardownIfNeeded() {
    _teardownInFlight ??= Completer<void>();
  }

  // 3. teardown 완료 알림
  void _finishTeardown() {
    final t = _teardownInFlight;
    if (t != null && !t.isCompleted) t.complete();
    _teardownInFlight = null;
  }

  // 초기화 + 프리뷰 시작
  Future<void> init({VideoConfig? vcfg, AudioConfig? acfg}) => _guard(() async {
    // 이전 종료가 진행 중이면 여기서 반드시 대기
    await _awaitTeardownIfAny();

    if (_disposed || _tearingDown) {
      Logger().w('(-1) init 실행 무시(종료/정리 중): disposed=$_disposed tearingDown=$_tearingDown');
      return;
    }
    Logger().d(
      '(0) init() 실행: '
      'initialized=$_initialized previewing=$_previewing streaming=$_streaming disposed=$_disposed',
    );

    state = state.copyWith(
      videoConfig: vcfg ?? state.videoConfig,
      audioConfig: acfg ?? state.audioConfig,
      clearError: true,
    );

    Logger().d('(1) state : $state');

    _streamCtrl ??= ApiVideoLiveStreamController(
      initialVideoConfig: state.videoConfig,
      initialAudioConfig: state.audioConfig,
      onConnectionSuccess: _onConnected,
      onConnectionFailed: (msg) => _onFailed("RTMP 연결 실패: $msg"),
      onDisconnection: _onDisconnected,
      onError: (e) => _onFailed("에러: $e"),
    );
    Logger().d(
      '(2) ApiVideoLiveStreamController 생성: '
      '(video=${state.videoConfig} / audio=${state.audioConfig})',
    );

    try {
      // 카메라/마이크 리소스 초기화
      if (!_initialized) {
        Logger().d('(3) controller.initialize() 실행');
        await _streamCtrl!.initialize();
        _initialized = true;
        Logger().d('(4) controller.initialize() 완료');
      }

      // 프리뷰가 아직 시작되지 않았다면 시작
      if (!_previewing) {
        Logger().d('(5) startPreview() 실행');
        await _streamCtrl!.startPreview(); // 카메라 프레임 표시 시작
        _previewing = true;
        Logger().d('(6) startPreview() 완료');

        if (_disposed) return;
        // 실제 RTMP 송출 중이 아니라면 상태를 previewing으로 갱신
        if (!_streaming) {
          Logger().d('(7) status : previewing 상태 변경');
          state = state.copyWith(
            status: PublisherStatus.previewing,
            clearError: true,
          );
        }
      }
    } catch (e) {
      Logger().e('(999) init() 실패: $e');
      _onFailed("카메라/마이크 초기화 또는 프리뷰 시작 실패: $e");
    }
  });

  bool get _hasValidTexture => (_streamCtrl?.textureId ?? 0) > 0;

  bool get _previewAlive => _initialized && _previewing && _hasValidTexture;

  /// 프리뷰가 죽어있으면 재시작하고, 인코더 워밍업을 잠깐 기다린다.
  Future<void> _ensureWarmPreview() async {
    if (_streamCtrl == null) {
      await init();
    }

    // 프리뷰가 안 떠있으면 켠다
    if (!_previewing) {
      await _streamCtrl!.startPreview();
      _previewing = true;
    }

    // --- 핵심: textureId > 0 될 때까지 기다린다 ---
    final ok = await _waitUntil(
      () => (_streamCtrl?.textureId ?? 0) > 0,
      const Duration(seconds: 3),
    );

    Logger().d('ensureWarmPreview: ok=$ok tex=${_streamCtrl?.textureId}');

    if (!ok) {
      _onFailed('카메라 프리뷰 준비 실패 (textureId=0)');
      throw StateError('preview texture is 0');
    }
  }

  Future<bool> _waitUntil(bool Function() cond, Duration timeout) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      if (cond()) return true;
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return cond();
  }

  // 방송 시작 (연결 시도 -> 콜백으로 live 반영)
  Future<void> startStreaming({
    required String streamKey,
  }) => _guard(() async {
    // 정리 중 재호출 차단
    if (_tearingDown || _disposed) return;

    final rtmpBaseUrl = dotenv.env['RTMP_BASE_URL'];
    Logger().d("(1) startStreaming 호출됨 streamKey=$streamKey rtmpBaseUrl=$rtmpBaseUrl");
    if (rtmpBaseUrl == null || rtmpBaseUrl.isEmpty || streamKey.isEmpty) {
      _onFailed("RTMP URL 또는 StreamKey가 비어있습니다.");
      Logger().e("(999) RTMP URL 또는 StreamKey 없음 → 실패");
      return;
    }

    await saveAccessToken("123"); // TODO : 토큰 추후 로그인 후 저장된 값 가져오도록 변경
    final token = await getAccessToken();
    Logger().d("(2) AccessToken 가져오기 시도 → token=$token");
    if (token == null || token.isEmpty) {
      _onFailed("AccessToken을 가져오지 못했습니다.");
      Logger().e("(999) AccessToken 없음 → 실패");
      return;
    }

    // 컨트롤러가 없거나 초기화 플래그가 꺼져 있으면 init()으로 지연 초기화.
    if (_streamCtrl == null || !_initialized) {
      Logger().d("(3) controller 존재X/초기화X → init() 실행");
      await init();
    }

    // 이미 connecting/live이면 재호출을 무시해 중복 연결 시도를 차단.
    if (state.status == PublisherStatus.live || state.status == PublisherStatus.connecting) {
      Logger().w("(999) 이미 ${state.status} 상태 → startStreaming 무시");
      return;
    }

    // 프리뷰가 꺼져있다면 켜고 시작
    if (!_previewing) {
      try {
        Logger().d("(4) startPreview() 실행");
        await _streamCtrl!.startPreview();
        _previewing = true;
        Logger().d("(5) startPreview() 완료");
      } catch (e) {
        _onFailed("프리뷰 시작 실패: $e");
        Logger().e("(999) startPreview 실패: $e");
        return;
      }
    }

    // finalKey = streamKey + token
    final finalKey = "$streamKey"; // TODO : 테스트 시에는 토큰 필요X 추후 ?token=$token 추가하기
    Logger().d("(6) 최종 StreamKey 생성: $finalKey");

    if (_disposed) {
      Logger().w("(999) 이미 disposed 상태 → startStreaming 중단");
      return;
    }

    // 프리뷰 보장 + 워밍업 (여기가 핵심)
    await _ensureWarmPreview();

    // 확인용 로그 (문제 재현 시 진단에 매우 유용)
    Logger().i(
      'before connect: previewAlive=$_previewAlive '
      'tex=${_streamCtrl?.textureId} '
      'video=${state.videoConfig} audio=${state.audioConfig}',
    );

    state = state.copyWith(
      status: PublisherStatus.connecting,
      clearError: true,
    );
    Logger().d("(7) status=connecting 상태로 변경");

    try {
      Logger().d("(8) _streamCtrl.startStreaming 호출 (url=$rtmpBaseUrl, key=$finalKey)");
      await _streamCtrl!.startStreaming(
        url: rtmpBaseUrl,
        streamKey: finalKey,
      );
      Logger().d("(9) startStreaming 요청 완료 → 결과는 콜백으로 반영됨");
      // 성공/실패는 콜백에서 최종 반영
    } catch (e) {
      _onFailed("방송 연결 시도 실패: $e");
      Logger().e("(999) startStreaming 실패: $e");
    }
  });

  // 방송 송출 시작 X, 프리뷰화면에서 뒤로가기 시 자원 정리
  Future<void> teardownPreview() async {
    // 이미 다른 곳에서 teardown 중이면 거기에 조인해서 "끝날 때까지 대기"하고 반환
    if (_teardownInFlight != null) {
      Logger().d('(0) teardown 이미 진행 중 → 조인 대기');
      await _teardownInFlight!.future;
      return;
    }

    if (_opBusy) {
      Logger().w('(999) teardownPreview 무시됨 → 이미 실행 중');
      return;
    }
    _opBusy = true;

    // 이번 호출이 teardown을 리드한다는 표식
    _beginTeardownIfNeeded();
    _tearingDown = true;

    Logger().d('(1) teardownPreview 시작');
    try {
      // 1) 스트리밍 중이면 우선 끊기
      if (_streaming || state.status == PublisherStatus.live || state.status == PublisherStatus.connecting) {
        try {
          await _streamCtrl?.stopStreaming();
        } catch (_) {}
        _streaming = false;
      }

      // 2) 프리뷰 정지
      if (_previewing) {
        Logger().d('(2) stopPreview 시도');
        try {
          await _streamCtrl?.stopPreview();
        } catch (_) {}
        Logger().d('(3) stopPreview 완료');
        _previewing = false;
      }

      // 3) 컨트롤러 dispose
      Logger().d('(4) dispose 시도');
      try {
        await _streamCtrl?.dispose();
      } catch (_) {}
      _streamCtrl = null;

      // 4) 일부 단말 안정화를 위한 짧은 간극
      await Future.delayed(const Duration(milliseconds: 200));

      _initialized = false;

      // 5) 상태 반영
      state = state.copyWith(status: PublisherStatus.idle);
    } finally {
      _tearingDown = false;
      _opBusy = false;

      // 모든 대기자에게 "끝났다" 신호
      _finishTeardown();
    }
  }

  // 내부: 완전 종료(방송/프리뷰/컨트롤러 정리)
  Future<void> _stopAndDispose() async {
    try {
      // 실행 중일 때만 stopStreaming 호출
      if (_streaming || state.status == PublisherStatus.live || state.status == PublisherStatus.connecting) {
        try {
          await _streamCtrl?.stopStreaming();
        } catch (_) {}
      }

      try {
        await _streamCtrl?.stopPreview();
      } catch (_) {}
      try {
        await _streamCtrl?.dispose();
      } catch (_) {}
    } catch (_) {}

    _streaming = false;
    _previewing = false;
    _initialized = false;
    _streamCtrl = null;

    if (!_disposed) {
      state = state.copyWith(status: PublisherStatus.stopped);
    }
  }

  // 외부: 명시 종료(재사용 불가)
  Future<void> shutdown() async {
    _tearingDown = true;
    await _stopAndDispose(); // 자원 완전 정리
    _disposed = true; // 이후 모든 퍼블릭 메서드 호출 차단
  }

  Future<void> toggleMute() async {
    if (_streamCtrl == null || !_initialized) {
      Logger().w("(999) toggleMute 호출 → 무시됨 (controller==null or !initialized)");
      return;
    }
    final next = !state.isMuted;
    try {
      Logger().d("(1) toggleMute 실행 → next=!state.isMuted=$next (현재 isMuted=${state.isMuted})");
      await _streamCtrl!.setIsMuted(next);
      if (_disposed) {
        Logger().w("(999) toggleMute 실행 도중 dispose됨");
        return;
      }
      state = state.copyWith(isMuted: next);
      Logger().d("(4) toggleMute 완료 → isMuted=$next");
    } catch (e) {
      _onFailed("음소거 전환 실패: $e");
      Logger().e("(999) toggleMute 실패: $e");
    }
  }

  Future<void> switchCamera() async {
    if (_streamCtrl == null || !_initialized) {
      Logger().w("(999) switchCamera 호출 → 무시됨 (controller==null or !initialized)");
      return;
    }
    try {
      Logger().d("(1) switchCamera 실행 (현재 isFrontCamera=${state.isFrontCamera})");
      await _streamCtrl!.switchCamera();
      if (_disposed) {
        Logger().w("(999) switchCamera 실행 도중 dispose됨");
        return;
      }
      state = state.copyWith(isFrontCamera: !state.isFrontCamera);
      Logger().d("(2) switchCamera 완료 → isFrontCamera=${!state.isFrontCamera}");
    } catch (e) {
      _onFailed("카메라 전환 실패: $e");
      Logger().e("(999) switchCamera 실패: $e");
    }
  }

  // 실행 중에 VideoConfig 변경
  Future<void> applyVideoConfig(VideoConfig cfg) async {
    if (_streamCtrl == null || !_initialized) return;
    try {
      await _streamCtrl!.setVideoConfig(cfg);
      if (_disposed) return;
      state = state.copyWith(videoConfig: cfg);
    } catch (e) {
      _onFailed("비디오 설정 적용 실패: $e");
    }
  }

  // 실행 중에 AudioConfig 변경
  Future<void> applyAudioConfig(AudioConfig cfg) async {
    if (_streamCtrl == null || !_initialized) return;
    try {
      await _streamCtrl!.setAudioConfig(cfg);
      if (_disposed) return;
      state = state.copyWith(audioConfig: cfg);
    } catch (e) {
      _onFailed("오디오 설정 적용 실패: $e");
    }
  }

  // RTMP 서버와 연결이 성공했을 때 호출되는 콜백
  void _onConnected() {
    Logger().d('(1) _onConnected 호출됨');
    _streaming = true;
    Logger().d('(2) _streaming = true');

    if (_disposed) {
      Logger().w('(999) 이미 disposed 상태 → 리턴');
      return;
    }

    state = state.copyWith(
      status: PublisherStatus.live,
      startedAt: DateTime.now(),
      clearError: true,
    );
    Logger().d('(3) state 갱신됨 → status=live, startedAt=${state.startedAt}');
    Logger().d('tex=${controller?.textureId}');
  }

  // RTMP 연결이 끊어졌을 때 호출되는 콜백
  void _onDisconnected() {
    Logger().d('(4) _onDisconnected 호출됨');
    _streaming = false;
    Logger().d('(5) _streaming = false');

    if (_disposed) {
      Logger().w('(999) 이미 disposed 상태 → 리턴');
      return;
    }

    final newStatus = _previewing ? PublisherStatus.previewing : PublisherStatus.stopped;
    state = state.copyWith(status: newStatus);
    Logger().d('(6) state 갱신됨 → status=$newStatus');
  }

  // RTMP 연결 실패나 오류 발생 시 호출되는 콜백
  void _onFailed(String msg) {
    Logger().d('(7) _onFailed 호출됨');
    _streaming = false;
    Logger().d('(8) _streaming = false');

    if (_disposed) {
      Logger().w('(999) 이미 disposed 상태 → 리턴');
      return;
    }

    state = state.copyWith(status: PublisherStatus.error, lastError: msg);
    Logger().e('(9) state 갱신됨 → status=error, lastError=$msg');
  }
}

class RtmpPublisherModel {
  final PublisherStatus status;
  final String? lastError;
  final VideoConfig videoConfig; // SDK 런타임 설정(= 실제로 인코더/컨트롤러가 쓰는 값)
  final AudioConfig audioConfig; // SDK 런타임 설정(= 실제로 인코더/컨트롤러가 쓰는 값)
  final bool isMuted;
  final bool isFrontCamera;
  final DateTime? startedAt;
  final int? currentVideoBitrate;
  final int? droppedFrames;

  final PublisherSettings settings;

  const RtmpPublisherModel({
    required this.status,
    this.lastError,
    required this.videoConfig,
    required this.audioConfig,
    this.isMuted = false,
    this.isFrontCamera = true,
    this.startedAt,
    this.currentVideoBitrate,
    this.droppedFrames,
    required this.settings,
  });

  RtmpPublisherModel copyWith({
    PublisherStatus? status,
    String? lastError,
    VideoConfig? videoConfig,
    AudioConfig? audioConfig,
    bool? isMuted,
    bool? isFrontCamera,
    DateTime? startedAt,
    int? currentVideoBitrate,
    int? droppedFrames,
    PublisherSettings? settings,
    bool clearError = false,
  }) {
    return RtmpPublisherModel(
      status: status ?? this.status,
      lastError: clearError ? null : (lastError ?? this.lastError),
      videoConfig: videoConfig ?? this.videoConfig,
      audioConfig: audioConfig ?? this.audioConfig,
      isMuted: isMuted ?? this.isMuted,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      startedAt: startedAt ?? this.startedAt,
      currentVideoBitrate: currentVideoBitrate ?? this.currentVideoBitrate,
      droppedFrames: droppedFrames ?? this.droppedFrames,
      settings: settings ?? this.settings,
    );
  }

  factory RtmpPublisherModel.initial() => RtmpPublisherModel(
    status: PublisherStatus.idle,
    // 비디오: 480p, 30fps (라이브러리의 480p 기본 비트레이트 사용)
    videoConfig: VideoConfig.withDefaultBitrate(
      resolution: Resolution.RESOLUTION_480,
      fps: 30,
    ),
    // 오디오: mono 96kbps, 44.1kHz
    audioConfig: AudioConfig(
      bitrate: 96_000,
      channel: Channel.mono,
      sampleRate: SampleRate.kHz_44_1,
      enableEchoCanceler: true,
      enableNoiseSuppressor: true,
    ),
    // settings : 표시/옵션용
    settings: PublisherSettings(
      video: VideoParams(
        preset: QualityPreset.p480,
        fps: FpsPreset.fps30,
        bitrate: 1_000_000,
      ),
      audio: const AudioParams(
        bitrate: 96_000,
      ),
    ),
  );
}

// 사용자 관점의 설정 값 모음
// TODO : UI에서 settings 변경 시 반드시 컨트롤러에도 반영 (매핑+적용) 지금은 적용 안되는, 표시용
class PublisherSettings {
  final VideoParams video;
  final AudioParams audio;
  final RtmpServerParams? server;
  const PublisherSettings({
    required this.video,
    required this.audio,
    this.server,
  });

  PublisherSettings copyWith({
    VideoParams? video,
    AudioParams? audio,
    RtmpServerParams? server,
  }) => PublisherSettings(
    video: video ?? this.video,
    audio: audio ?? this.audio,
    server: server ?? this.server,
  );

  factory PublisherSettings.default720_30() => PublisherSettings(
    video: VideoParams(
      preset: QualityPreset.p720,
      fps: FpsPreset.fps30,
      bitrate: 2_500_000,
    ),
    audio: const AudioParams(),
  );
}
