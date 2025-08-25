import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/pages/live/stream_page/widgets/live_stream_setting_sheet.dart';
import 'package:laviu_flutter/ui/widgets/m_dialog.dart';

class LiveStreamIconBar extends StatefulWidget {
  const LiveStreamIconBar({
    super.key,
    required this.onStop,
    this.onToggleMute,
    this.onSwitchCamera,
    this.isMuted = false,
    this.isFrontCamera = true,
    this.startedAt,
  });

  final VoidCallback onStop;
  final VoidCallback? onToggleMute; // null이면 자동 비활성화
  final VoidCallback? onSwitchCamera; // null이면 자동 비활성화
  final bool isMuted;
  final bool isFrontCamera;
  final DateTime? startedAt;

  @override
  State<LiveStreamIconBar> createState() => _LiveStreamIconBarState();
}

class _LiveStreamIconBarState extends State<LiveStreamIconBar> {
  Timer? _timer; // 1초마다 콜백을 실행해주는 타이머
  Duration _elapsed = Duration.zero; // startedAt부터 지금까지 흐른 누적 시간을 담아두는 곳

  @override
  void initState() {
    super.initState();
    _startOrStopTimer();
  }

  // 부모로부터 받은 startedAt이 변경되는 경우 (시작 시각이 바뀌면 타이머를 다시 세팅)
  @override
  void didUpdateWidget(covariant LiveStreamIconBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startedAt != widget.startedAt) {
      _startOrStopTimer();
    }
  }

  // 타이머 켜고/끄기
  void _startOrStopTimer() {
    _timer?.cancel(); // 기존 타이머 정리

    if (widget.startedAt == null) {
      // 시작시각 없으면 경과시간 0으로 표시
      setState(() => _elapsed = Duration.zero);
      return; // 타이머 돌리지 X
    }

    // 시작시각 있으면 지금 시각과의 차이를 바로 한 번 계산해서 표시
    setState(() {
      final difference = DateTime.now().difference(widget.startedAt!);
      _elapsed = difference.isNegative ? Duration.zero : difference;
    });

    // 매초마다 경과시간을 갱신하도록 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || widget.startedAt == null) return; // 중간에 startedAt이 지워질 수도 있으니 체크
      final diff = DateTime.now().difference(widget.startedAt!);
      setState(() {
        _elapsed = diff.isNegative ? Duration.zero : diff;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration duration) {
    String _twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${_twoDigits(duration.inHours)}:${_twoDigits(duration.inMinutes.remainder(60))}:${_twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    final timeLabel = widget.startedAt == null ? '--:--:--' : _format(_elapsed);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MSizes.gapM, vertical: MSizes.gapM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 라이브 진행 시간
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MSizes.gapM, vertical: MSizes.gapXS),
              decoration: BoxDecoration(
                color: MColors.primaryAccent.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(MSizes.radiusCircle),
              ),
              child: Text(
                timeLabel,
                style: TextStyle(color: MColors.white, fontWeight: FontWeight.w900, fontSize: MSizes.fontNormal),
              ),
            ),
          ),
          Row(
            children: [
              // 마이크 설정 버튼
              IconButton(
                tooltip: widget.isMuted ? '마이크 켜기' : '마이크 끄기',
                icon: Icon(widget.isMuted ? Icons.mic_off : Icons.mic, color: MColors.white),
                onPressed: widget.onToggleMute,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 가로/세로 화면 전환 버튼
              IconButton(
                icon: Icon(Icons.screen_rotation, color: MColors.white),
                onPressed: () {}, // TODO : 가로/세로 화면 전환 추후 처리
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 카메라 전/후면 전환 버튼
              IconButton(
                tooltip: widget.isFrontCamera ? '후면으로 전환' : '전면으로 전환',
                icon: Icon(Icons.flip_camera_ios, color: MColors.white),
                onPressed: widget.onSwitchCamera,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 방송 설정 버튼
              IconButton(
                icon: Icon(Icons.settings, color: MColors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: false,
                    backgroundColor: MColors.backgroundNormal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                    ),
                    builder: (BuildContext sheetContext) {
                      return LiveStreamSettingSheet();
                    },
                  );
                },
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                iconSize: 24,
              ),
              // 종료 버튼
              Padding(
                padding: EdgeInsets.only(left: MSizes.gapS, right: 15),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(MColors.grey),
                    minimumSize: WidgetStatePropertyAll(Size.zero),
                    visualDensity: VisualDensity(horizontal: 0, vertical: -1.3),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(MSizes.radiusS)),
                    ),
                  ),
                  child: Text(
                    '종료',
                    style: TextStyle(color: MColors.white, fontWeight: FontWeight.w900, fontSize: MSizes.fontNormal),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return MDialog(
                          title: '방송을 종료하시겠어요?',
                          message: '지금 방송을 종료하면 저장되지 않아요.\n 정말 방송을 종료하시겠어요?',
                          primaryText: '종료',
                          primaryColor: MColors.primaryDanger,
                          onPrimaryTap: widget.onStop,
                          secondaryText: '취소',
                          onSecondaryTap: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
