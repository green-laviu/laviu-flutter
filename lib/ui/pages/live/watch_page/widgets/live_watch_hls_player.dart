import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/_core/utils/m_hls.dart';

class LiveWatchHlsPlayer extends StatefulWidget {
  final String origin; // http://host:port
  final String streamKey; // {streamKey}
  final LiveQuality initialQuality;

  // ⬇️ 추가: 테스트용 URL (마스터 m3u8)
  final String? overrideMasterUrl;

  const LiveWatchHlsPlayer({
    super.key,
    required this.origin,
    required this.streamKey,
    this.initialQuality = LiveQuality.auto,
    this.overrideMasterUrl, // ⬅️ 추가 (테스트용)
  });

  @override
  State<LiveWatchHlsPlayer> createState() => _LiveWatchHlsPlayerState();
}

class _LiveWatchHlsPlayerState extends State<LiveWatchHlsPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _c;
  LiveQuality _quality = LiveQuality.auto;
  bool _loading = false;
  String? _error;
  bool _show = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _quality = widget.initialQuality;
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _c?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _c;
    if (c == null) return;
    if (state == AppLifecycleState.paused) c.pause();
    if (state == AppLifecycleState.resumed && !c.value.isPlaying) c.play();
  }

  String _buildUrl() {
    if (widget.overrideMasterUrl != null) {
      // 테스트 모드: 항상 마스터(Adaptive) 재생
      return widget.overrideMasterUrl!;
    }
    if (_quality == LiveQuality.auto) {
      return MHlsUrl.master(origin: widget.origin, streamKey: widget.streamKey);
    }
    final q = switch (_quality) {
      LiveQuality.p1080 => '1080p',
      LiveQuality.p720 => '720p',
      LiveQuality.p480 => '480p',
      LiveQuality.auto => '1080p', // not used
    };
    return MHlsUrl.fixed(
      origin: widget.origin,
      streamKey: widget.streamKey,
      quality: q,
    );
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final old = _c;
    final url = _buildUrl();

    final c = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..setLooping(true);

    try {
      await c.initialize();
      await c.play();
      setState(() {
        _c = c;
        _loading = false;
      });
      old?.dispose();
      _autoHide();
    } catch (e) {
      c.dispose();
      setState(() {
        _loading = false;
        _error = '재생 실패: $e';
      });
    }
  }

  void _autoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _show = false);
    });
  }

  Future<void> _pickQuality() async {
    final q = await showModalBottomSheet<LiveQuality>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.black87,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final opt in LiveQuality.values)
              ListTile(
                title: Text(
                  opt.label,
                  style: MText.label1Medium(
                    color: _quality == opt ? Colors.white : Colors.white70,
                  ),
                ),
                trailing: _quality == opt
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
                onTap: () => Navigator.of(ctx).pop(opt),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (q != null && q != _quality) {
      setState(() => _quality = q);
      await _c?.pause();
      await _init(); // URL 교체
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _show = !_show);
        if (_show) _autoHide();
      },
      child: AspectRatio(
        aspectRatio: (c?.value.aspectRatio ?? 16 / 9) == 0
            ? 16 / 9
            : (c?.value.aspectRatio ?? 16 / 9),
        child: Stack(
          children: [
            // 비디오 or 로딩/에러
            Positioned.fill(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _ErrorView(message: _error!, onRetry: _init)
                  : (c == null || !c.value.isInitialized)
                  ? const SizedBox.shrink()
                  : VideoPlayer(c),
            ),

            // 상단 좌측 LIVE Pill
            Positioned(
              left: 8,
              top: 8 + MediaQuery.of(context).padding.top,
              child: _Faded(
                visible: _show,
                child: _pill('LIVE', const Color(0xFFE53935)),
              ),
            ),

            // 상단 우측: 화질/새로고침
            Positioned(
              right: 8,
              top: 8 + MediaQuery.of(context).padding.top,
              child: _Faded(
                visible: _show,
                child: Row(
                  children: [
                    _miniBadge(_quality.label),
                    IconButton(
                      icon: const Icon(Icons.hd, color: Colors.white),
                      onPressed: _pickQuality,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _init,
                    ),
                  ],
                ),
              ),
            ),

            // 하단: 재생/일시정지
            Positioned(
              left: 0,
              right: 0,
              bottom: 8 + MediaQuery.of(context).padding.bottom,
              child: _Faded(
                visible: _show,
                child: Center(
                  child: IconButton(
                    iconSize: 56,
                    color: Colors.white,
                    icon: Icon(
                      (c?.value.isPlaying ?? false)
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                    ),
                    onPressed: () {
                      if (c == null) return;
                      c.value.isPlaying ? c.pause() : c.play();
                      setState(() {});
                      _autoHide();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Faded extends StatelessWidget {
  final bool visible;
  final Widget child;
  const _Faded({required this.visible, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      child: IgnorePointer(ignoring: !visible, child: child),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 36),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

Widget _pill(String text, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(text, style: MText.label2Bold(color: Colors.white)),
);

Widget _miniBadge(String text) => Container(
  margin: const EdgeInsets.only(right: 8),
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.5),
    borderRadius: BorderRadius.circular(999),
    border: Border.all(color: Colors.white24),
  ),
  child: Text(text, style: MText.label2Medium(color: Colors.white)),
);
