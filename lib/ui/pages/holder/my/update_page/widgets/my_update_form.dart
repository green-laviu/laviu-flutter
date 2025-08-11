import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/widgets/my_update_elevated_btn.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/widgets/my_update_profile_img_btn.dart';
import 'package:laviu_flutter/ui/pages/holder/my/update_page/widgets/my_update_text_form_field.dart';

class MyUpdateForm extends StatefulWidget {
  const MyUpdateForm({super.key});

  @override
  State<MyUpdateForm> createState() => _MyUpdateFormState();
}

class _MyUpdateFormState extends State<MyUpdateForm> {
  final scroll = ScrollController();

  // 실제 크기 측정을 위한 키들
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _btnKey = GlobalKey();

  double _cardH = 0;
  double _btnH = 0;
  double _bodyH = 0;

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Scaffold body 높이(AppBar 제외)
        final bodyH = constraints.maxHeight;

        // 다음 프레임에서 카드/버튼 실제 높이 측정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final cardH = _cardKey.currentContext?.size?.height ?? 0;
          final btnH = _btnKey.currentContext?.size?.height ?? 0;

          if (cardH != _cardH || btnH != _btnH || bodyH != _bodyH) {
            setState(() {
              _cardH = cardH;
              _btnH = btnH;
              _bodyH = bodyH;
            });
          }
        });

        // 버튼 위/아래 기본 여백(디자인 여유)
        const double buttonTopGap = 8.0;
        const double buttonBottomGap = 16.0;

        // 남는 공간 = 바디 - 카드 - 버튼 - (버튼 위/아래 기본 여백)
        final double remaining = _bodyH - _cardH - _btnH - buttonTopGap - buttonBottomGap;

        // 키보드 없을 때만 남는 공간을 ListView 바닥 패딩으로 채움
        final double bottomGapForList = isKeyboardVisible ? 0 : (remaining > 0 ? remaining : 0);

        return Form(
          child: Column(
            children: [
              // 스크롤 영역
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: EdgeInsets.only(bottom: bottomGapForList),
                  children: [
                    Card(
                      key: _cardKey, // 카드 실제 높이 측정
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: MSizes.gapL,
                          end: MSizes.gapL,
                          top: MSizes.gapHuge,
                          bottom: MSizes.gapL,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyUpdateProfileImgBtn(),
                            SizedBox(height: MSizes.gapXL),

                            // 닉네임
                            Text('닉네임', style: MText.label1Medium(color: MColors.textNormal)),
                            SizedBox(height: MSizes.gapS),
                            MyUpdateTextFormField(
                              hintText: '닉네임',
                              maxLength: 20,
                              initialValue: '다승왕박세웅',
                              onChanged: (v) {},
                              onTap: () {},
                            ),
                            SizedBox(height: MSizes.gapM),

                            // 채널 소개
                            Text('채널 소개', style: MText.label1Medium(color: MColors.textNormal)),
                            SizedBox(height: MSizes.gapS),
                            MyUpdateTextFormField(
                              hintText: '채널 소개',
                              maxLength: 150,
                              maxLines: null, // 자동 확장 원하면 사용
                              initialValue: '다승왕박세웅님의 채널입니다.',
                              onChanged: (v) {},
                              onTap: () {
                                // 탭 시 한 프레임 뒤 바닥으로 부드럽게 스크롤
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (!mounted) return;
                                  scroll.animateTo(
                                    scroll.position.maxScrollExtent,
                                    duration: MSizes.animDurationNormal,
                                    curve: Curves.easeOut,
                                  );
                                });
                              },
                            ),
                            SizedBox(height: MSizes.gapL),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 하단 버튼: 안전영역 + 키보드 높이만큼 부드럽게 상승
              SafeArea(
                top: false,
                child: AnimatedPadding(
                  duration: MSizes.animDurationFast,
                  curve: Curves.easeOut,
                  padding: EdgeInsets.fromLTRB(
                    MSizes.gapM,
                    buttonTopGap, // 버튼 위 여유
                    MSizes.gapM,
                    keyboardHeight, // 키보드 높이 반영
                  ),
                  child: SizedBox(
                    key: _btnKey, // 버튼 실제 높이 측정
                    width: double.infinity,
                    child: MyUpdateElevatedBtn(
                      text: '수정',
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
