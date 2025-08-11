import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '이 방송 어때요?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: MColors.textNeutral,
                ),
              ),
            ),
            TextButton(
              onPressed: () {}, // TODO: 더보기
              child: Text(
                '더보기',
                style: MText.label2Bold(color: MColors.primaryStrong),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
