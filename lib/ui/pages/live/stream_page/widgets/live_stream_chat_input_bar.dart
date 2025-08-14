import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:logger/logger.dart';

class LiveStreamChatInputBar extends StatelessWidget {
  const LiveStreamChatInputBar({
    super.key,
    required TextEditingController msgCtrl,
  }) : _msgCtrl = msgCtrl;

  final TextEditingController _msgCtrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 입력 필드
        Expanded(
          child: TextField(
            controller: _msgCtrl,
            style: MText.inputMedium(color: MColors.textWhite),
            cursorColor: MColors.white,
            decoration: InputDecoration(
              isDense: true,
              hintText: "메시지를 입력하세요",
              hintStyle: MText.inputMedium(color: MColors.textWhite),
              contentPadding: EdgeInsets.symmetric(
                horizontal: MSizes.gapM,
                vertical: MSizes.gapM,
              ), // 내부 여백
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MSizes.radiusXL),
                borderSide: BorderSide(color: MColors.primaryStrong, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MSizes.radiusXL),
                borderSide: BorderSide(color: MColors.primaryStrong, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MSizes.radiusXL),
                borderSide: BorderSide(color: MColors.primaryStrong, width: 2),
              ),
            ),
            onSubmitted: (value) {
              _msgCtrl.clear();
            },
          ),
        ),
        // 전송 버튼
        GestureDetector(
          onTap: () {
            Logger().d("전송 버튼 클릭");
          },
          child: Padding(
            padding: EdgeInsets.only(left: MSizes.gapL),
            child: Icon(Icons.send, color: MColors.white, size: MSizes.iconM),
          ),
        ),
      ],
    );
  }
}
