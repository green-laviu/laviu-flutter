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

final rtmpPublisherProvider =
    NotifierProvider<RtmpPublisherGVM, RtmpPublisherModel>(
      () => RtmpPublisherGVM(),
    );

class RtmpPublisherGVM extends Notifier<RtmpPublisherModel> {
  ApiVideoLiveStreamController? _streamCtrl;

  bool _initialized = false; // initialize() 호출했는지
  bool _previewing = false; // startPreview() 중인지 (프리뷰 중복 시작 방지)
  bool _streaming = false; // 방송 중인지 (실제 RTMP 송출 중 여부. 프리뷰 상태 표시 판단에 사용)
  bool _disposed = false; // 이 Notifier가 폐기(dispose)됐는지
  bool _opBusy = false; // 동시에 같은 작업이 겹치지 않게 하는 락

  ApiVideoLiveStreamController? get controller => _streamCtrl;

  @override
  RtmpPublisherModel build() {
    // 컨테이너가 실제 dispose될 때 최종 정리
    ref.onDispose(() {
      _disposed = true;
      _stopAndDispose(); // 프리뷰/방송/컨트롤러 안전 종료
    });

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

  // 초기화 + 프리뷰 시작
  Future<void> init({VideoConfig? vcfg, AudioConfig? acfg}) => _guard(() async {
    state = state.copyWith(
      videoConfig: vcfg ?? state.videoConfig,
      audioConfig: acfg ?? state.audioConfig,
      clearError: true,
    );

    _streamCtrl ??= ApiVideoLiveStreamController(
      initialVideoConfig: state.videoConfig,
      initialAudioConfig: state.audioConfig,
      onConnectionSuccess: _onConnected,
      onConnectionFailed: (msg) => _onFailed("RTMP 연결 실패: $msg"),
      onDisconnection: _onDisconnected,
      onError: (e) => _onFailed("에러: $e"),
    );

    try {
      // 카메라/마이크 리소스 초기화
      if (!_initialized) {
        await _streamCtrl!.initialize();
        _initialized = true;
      }

      // 프리뷰가 아직 시작되지 않았다면 시작
      if (!_previewing) {
        await _streamCtrl!.startPreview(); // 카메라 프레임 표시 시작
        _previewing = true;

        if (_disposed) return;
        // 실제 RTMP 송출 중이 아니라면 상태를 previewing으로 갱신
        if (!_streaming) {
          state = state.copyWith(
            status: PublisherStatus.previewing,
            clearError: true,
          );
        }
      }
    } catch (e) {
      _onFailed("카메라/마이크 초기화 또는 프리뷰 시작 실패: $e");
    }
  });

  // 방송 시작 (연결 시도 -> 콜백으로 live 반영)
  Future<void> startStreaming({
    required String streamKey,
  }) => _guard(() async {
    final rtmpBaseUrl = dotenv.env['RTMP_BASE_URL'];
    if (rtmpBaseUrl == null || rtmpBaseUrl.isEmpty || streamKey.isEmpty) {
      _onFailed("RTMP URL 또는 StreamKey가 비어있습니다.");
      return;
    }

    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      _onFailed("AccessToken을 가져오지 못했습니다.");
      return;
    }

    // 컨트롤러가 없거나 초기화 플래그가 꺼져 있으면 init()으로 지연 초기화.
    if (_streamCtrl == null || !_initialized) {
      await init();
    }

    // 이미 connecting/live이면 재호출을 무시해 중복 연결 시도를 차단.
    if (state.status == PublisherStatus.live ||
        state.status == PublisherStatus.connecting) {
      return;
    }

    // 프리뷰가 꺼져있다면 켜고 시작
    if (!_previewing) {
      try {
        await _streamCtrl!.startPreview();
        _previewing = true;
      } catch (e) {
        _onFailed("프리뷰 시작 실패: $e");
        return;
      }
    }

    // finalKey = streamKey + token
    final finalKey = "$streamKey?token=$token";

    if (_disposed) return;
    state = state.copyWith(
      status: PublisherStatus.connecting,
      clearError: true,
    );

    try {
      await _streamCtrl!.startStreaming(
        url: rtmpBaseUrl,
        streamKey: finalKey,
      );
      // 성공/실패는 콜백에서 최종 반영
    } catch (e) {
      _onFailed("방송 연결 시도 실패: $e");
    }
  });

  // 내부: 완전 종료(방송/프리뷰/컨트롤러 정리)
  Future<void> _stopAndDispose() async {
    try {
      await _streamCtrl?.stopStreaming();
    } catch (_) {}
    try {
      await _streamCtrl?.stopPreview();
    } catch (_) {}
    try {
      await _streamCtrl?.dispose();
    } catch (_) {}

    _streaming = false;
    _previewing = false;
    _initialized = false;
    _streamCtrl = null;

    // VM이 아직 유효하면 UI에 stopped 반영
    if (!_disposed) {
      state = state.copyWith(status: PublisherStatus.stopped);
    }
  }

  // 외부: 명시 종료(재사용 불가)
  Future<void> shutdown() async {
    await _stopAndDispose(); // 자원 완전 정리
    _disposed = true; // 이후 모든 퍼블릭 메서드 호출 차단
  }

  Future<void> toggleMute() async {
    if (_streamCtrl == null || !_initialized) return;
    final next = !state.isMuted;
    try {
      await _streamCtrl!.setIsMuted(next);
      if (_disposed) return;
      state = state.copyWith(isMuted: next);
    } catch (e) {
      _onFailed("음소거 전환 실패: $e");
    }
  }

  Future<void> switchCamera() async {
    if (_streamCtrl == null || !_initialized) return;
    try {
      await _streamCtrl!.switchCamera();
      if (_disposed) return;
      state = state.copyWith(isFrontCamera: !state.isFrontCamera);
    } catch (e) {
      _onFailed("카메라 전환 실패: $e");
    }
  }

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

  void _onConnected() {
    _streaming = true;
    if (_disposed) return;
    state = state.copyWith(
      status: PublisherStatus.live,
      startedAt: DateTime.now(),
      clearError: true,
    );
  }

  void _onDisconnected() {
    _streaming = false;
    if (_disposed) return;
    state = state.copyWith(
      status: _previewing
          ? PublisherStatus.previewing
          : PublisherStatus.stopped,
    );
  }

  void _onFailed(String msg) {
    _streaming = false;
    if (_disposed) return;
    state = state.copyWith(status: PublisherStatus.error, lastError: msg);
  }
}

class RtmpPublisherModel {
  final PublisherStatus status;
  final String? lastError;
  final VideoConfig videoConfig;
  final AudioConfig audioConfig;
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
    videoConfig: VideoConfig.withDefaultBitrate(),
    audioConfig: AudioConfig(),
    settings: PublisherSettings.default720_30(),
  );
}

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
