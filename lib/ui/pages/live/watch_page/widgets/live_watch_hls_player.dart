import 'dart:async';
import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:video_player/video_player.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/_core/utils/m_hls.dart';

class LiveWatchHlsPlayer extends StatefulWidget {
  final String origin; // http://host:port
  final String streamKey; // {streamKey}
  final LiveQuality initialQuality;

  /// 서버가 내려준 마스터 m3u8 (있으면 이걸로 ABR 재생. 수동 화질 변경 비활성)
  final String? overrideMasterUrl;

  const LiveWatchHlsPlayer({
    super.key,
    required this.origin,
    required this.streamKey,
    this.initialQuality = LiveQuality.p1080,
    this.overrideMasterUrl,
  });

  @override
  State<LiveWatchHlsPlayer> createState() => _LiveWatchHlsPlayerState();
}

class _LiveWatchHlsPlayerState extends State<LiveWatchHlsPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _c;
  LiveQuality _quality = LiveQuality.p1080;
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
    // 마스터 m3u8이 있으면 우선 사용(자동 화질)
    if (widget.overrideMasterUrl != null) return widget.overrideMasterUrl!;
    // 없으면 고정식(수동 화질 변경 가능)
    return MHlsUrl.fixed(
      origin: widget.origin,
      streamKey: widget.streamKey,
      quality: _quality.slug, // '1080p' | '720p' | '480p'
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

  Future<void> _showActionsSheet() async {
    final canSelectQuality = widget.overrideMasterUrl == null; // 마스터면 비활성
    final label = _quality.label; // '1080p' ...

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canSelectQuality)
                ListTile(
                  leading: const Icon(Icons.high_quality),
                  title: Text('해상도 $label'),
                  onTap: () => Navigator.pop(ctx, 'quality'),
                )
              else
                ListTile(
                  leading: const Icon(Icons.high_quality),
                  title: const Text('자동 화질 (마스터 m3u8)'),
                  subtitle: const Text('수동 변경은 지원되지 않아요'),
                  enabled: false,
                ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('신고하기'),
                onTap: () => Navigator.pop(ctx, 'report'),
              ),
            ],
          ),
        );
      },
    );

    if (selected == 'quality' && canSelectQuality) {
      await _showQualitySheet();
    } else if (selected == 'report') {
      // TODO: 신고 플로우
    }
  }

  Future<void> _showQualitySheet() async {
    final picked = await showModalBottomSheet<LiveQuality>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        Widget item(LiveQuality q, String title) {
          final sel = _quality == q;
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
            title: Text(
              title,
              style: TextStyle(
                color: MColors.textNormal,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: sel ? Icon(Icons.check, color: MColors.textNormal) : null,
            onTap: () => Navigator.pop(ctx, q),
          );
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              top: MSizes.gapM,
              bottom: MediaQuery.of(ctx).padding.bottom + MSizes.gapM,
              left: MSizes.gapL,
              right: MSizes.gapL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Padding(
                  padding: EdgeInsets.symmetric(vertical: MSizes.gapS),
                  child: Text(
                    '화질',
                    style: MText.heading3Bold(color: MColors.textNormal),
                  ),
                ),
                // 항목 (체크는 현재 선택만)
                item(LiveQuality.p1080, '고화질 (1080p)'),
                item(LiveQuality.p720, '일반화질 (720p)'),
                item(LiveQuality.p480, '저화질 (480p)'),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null && picked != _quality) {
      setState(() => _quality = picked);
      await _c?.pause();
      await _init();
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

            // 상단 우측 메뉴
            Positioned(
              right: 8,
              top: 8 + MediaQuery.of(context).padding.top,
              child: _Faded(
                visible: _show,
                child: IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white),
                  onPressed: _showActionsSheet,
                  tooltip: '메뉴',
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
