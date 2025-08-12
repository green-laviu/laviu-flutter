import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';

class LivePreviewPage extends StatelessWidget {
  const LivePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: 카메라 프리뷰 위젯으로 교체
          Container(color: MColors.primary),

          // TODO: 상단 아이콘바 자리 (좌: 닫기 / 우: 마이크, 가로모드, 카메라전환, 설정)

          // TODO: 좌측 상단 제목 입력 필드 자리

          // TODO: 제목 아래 해시태그(칩 + 입력 필드) 자리

          // TODO: 하단 중앙 '생방송 시작하기' 버튼 자리
        ],
      ),
    );
  }
}
