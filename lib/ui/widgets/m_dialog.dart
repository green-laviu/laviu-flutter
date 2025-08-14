import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class MDialog extends StatelessWidget {
  final String? title;
  final String? message;

  /// 주 버튼(오른쪽/단일 버튼)
  final String primaryText;
  final VoidCallback onPrimaryTap;
  final Color? primaryColor;

  /// 보조 버튼(왼쪽). 없으면 단일 버튼 형태
  final String? secondaryText;
  final VoidCallback? onSecondaryTap;
  final Color? secondaryColor;

  const MDialog({
    super.key,
    this.title,
    this.message,
    required this.primaryText,
    required this.onPrimaryTap,
    this.primaryColor = MColors.textNormal,
    this.secondaryText,
    this.onSecondaryTap,
    this.secondaryColor = MColors.textNeutral,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: MColors.backgroundNormal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MSizes.radiusXL),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380), // 태블릿 사용시 대비?
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: MSizes.gapL,
                right: MSizes.gapL,
                top: MSizes.gapL,
                bottom: MSizes.gapM,
              ),
              child: Column(
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: MText.heading3SemiBold(color: MColors.textNormal),
                    ),
                    SizedBox(height: MSizes.gapS),
                  ],
                  if (message != null) ...[
                    SizedBox(height: MSizes.gapS),
                    Text(
                      message!,
                      textAlign: TextAlign.center,
                      style: MText.label1SemiBold(color: MColors.textNeutral),
                    ),
                  ],
                ],
              ),
            ),
            Divider(color: MColors.lineNormal, height: 1, indent: 0, endIndent: 0),

            if (secondaryText != null && onSecondaryTap != null) ...[
              SizedBox(
                height: 54,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 왼쪽 보조 버튼
                    Expanded(
                      child: InkWell(
                        onTap: onSecondaryTap,
                        child: Center(
                          child: Text(
                            secondaryText!,
                            style: TextStyle(color: secondaryColor, fontSize: MSizes.fontM),
                            strutStyle: StrutStyle(forceStrutHeight: true, height: 1.0, leading: 0),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(color: MColors.fillContrast, width: 1, indent: 0, endIndent: 0),
                    // 오른쪽 주 버튼
                    Expanded(
                      child: InkWell(
                        onTap: onPrimaryTap,
                        child: Center(
                          child: Text(
                            primaryText,
                            style: TextStyle(color: primaryColor, fontSize: MSizes.fontM), // MColors.primaryDanger
                            strutStyle: StrutStyle(forceStrutHeight: true, height: 1.0, leading: 0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                height: 54,
                child: Expanded(
                  child: InkWell(
                    onTap: onPrimaryTap,
                    child: Center(
                      child: Text(
                        primaryText,
                        style: TextStyle(color: primaryColor, fontSize: MSizes.fontM), // MColors.primaryDanger
                        strutStyle: StrutStyle(forceStrutHeight: true, height: 1.0, leading: 0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
