import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/ui/widgets/m_btn.dart';

class LivePreviewPage extends StatelessWidget {
  const LivePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // TODO: 카메라 프리뷰 위젯으로 교체
          Container(color: MColors.primaryContainer),

          // TODO: 상단 아이콘바 자리 (좌: 닫기 / 우: 마이크, 가로모드, 카메라전환, 설정)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: MSizes.gapM, vertical: MSizes.gapM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: MColors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.mic, color: MColors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.screen_rotation, color: MColors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.flip_camera_ios, color: MColors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.settings, color: MColors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // TODO: 좌측 상단 제목 입력 필드 자리 + 제목 아래 해시태그(칩 + 입력 필드) 자리
          Positioned(
            left: MSizes.gapXXL,
            right: MSizes.gapXXL,
            top: 110,
            child: Form(
              child: Column(
                children: [
                  // 제목 입력 필드
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '제목',
                      hintStyle: TextStyle(
                        fontSize: MSizes.fontXXL,
                        fontWeight: FontWeight.w700,
                        color: MColors.textWhite,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: MSizes.fontXXL,
                      fontWeight: FontWeight.w700,
                      color: MColors.textWhite,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '제목을 입력하세요';
                      return null;
                    },
                    onChanged: (value) {},
                  ),
                  // 해시태그 입력 필드
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '해시태그',
                      hintStyle: TextStyle(
                        fontSize: MSizes.fontM,
                        fontWeight: FontWeight.w700,
                        color: MColors.textWhite,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: MSizes.fontM,
                      fontWeight: FontWeight.w700,
                      color: MColors.textWhite,
                    ),
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),

          // TODO: 하단 중앙 '생방송 시작하기' 버튼 자리
          Positioned(
            left: MSizes.gapXXL,
            right: MSizes.gapXXL,
            bottom: 0,
            child: SafeArea(
              child: MBtn(
                text: '생방송 시작하기',
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
