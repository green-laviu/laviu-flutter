import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';

class LiveStreamChatMsg extends StatelessWidget {
  final bool isStreamer;
  final String nickName;
  final String msg;

  const LiveStreamChatMsg({
    super.key,
    this.isStreamer = false,
    required this.nickName,
    required this.msg,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          isStreamer
              ? WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Icon(
                    CupertinoIcons.mic_solid,
                    color: MColors.primaryDanger,
                    size: MSizes.fontM,
                  ),
                )
              : WidgetSpan(child: SizedBox.shrink()),
          TextSpan(
            text: '$nickName     ',
            style: GoogleFonts.doHyeon(
              color: isStreamer ? MColors.primaryDanger : MColors.primaryStrong,
              fontSize: MSizes.fontM,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: msg,
            style: GoogleFonts.doHyeon(
              color: MColors.white,
              fontSize: MSizes.fontM,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
