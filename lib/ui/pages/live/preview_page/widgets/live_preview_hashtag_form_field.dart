import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/_core/utils/m_util.dart';
import 'package:laviu_flutter/ui/pages/live/preview_page/live_preview_fm.dart';

class LivePreviewHashtagFormField extends ConsumerStatefulWidget {
  const LivePreviewHashtagFormField({
    super.key,
  });

  @override
  ConsumerState<LivePreviewHashtagFormField> createState() =>
      _LivePreviewHashtagFormFieldState();
}

class _LivePreviewHashtagFormFieldState
    extends ConsumerState<LivePreviewHashtagFormField> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _scrollCtrl = ScrollController();
  final List<String> _savedTagList = []; // # 없는 태그 리스트
  String? _errorMsg;

  void _addParsedHashtags(String tag) {
    bool changed = false;

    List<String> parsedTagList = parseTagList(tag);
    for (final tag in parsedTagList) {
      if (_savedTagList.length >= 3) break;

      final normalizedTag = normalizeHashtag(tag);
      if (normalizedTag == null) continue;

      if (isDuplicateTagIgnoreCase(_savedTagList, normalizedTag)) {
        setState(() => _errorMsg = '이미 추가한 해시태그예요.');
        continue;
      }
      setState(() {
        _savedTagList.add(normalizedTag);
        _errorMsg = null;
        changed = true;
      });
    }

    if (changed) {
      ref
          .read(livePreviewProvider.notifier)
          .hashtagList(List.of(_savedTagList));
    }

    // 해시태그 추가 후 스크롤을 맨 오른쪽으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: MSizes.animDurationFast,
          curve: Curves.easeOut,
        );
      }
    });

    _ctrl.clear();
    _focus.requestFocus(); // 커서 재활성화
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LivePreviewFM fm = ref.read(livePreviewProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _ctrl,
          focusNode: _focus,
          onFieldSubmitted: (value) {
            if (value.trim().isEmpty) return;
            if (_savedTagList.length >= 3) {
              setState(() => _errorMsg = '해시태그는 최대 3개까지 추가할 수 있어요.');
              _ctrl.clear();
              return;
            }
            _addParsedHashtags(value);
          }, // 버튼/엔터 눌렀을 때만 호출
          onChanged: (value) {
            // 한글 IME 조합 중 확정(commit) 예방
            final composing = _ctrl.value.composing;
            final isComposing = composing.isValid && !composing.isCollapsed;
            if (isComposing) return; // = 조합 중

            // 스페이스/쉼표 입력 시 태그 입력 종료
            if (value.isNotEmpty && RegExp(r'[,\s]$').hasMatch(value)) {
              if (_savedTagList.length >= 3) {
                setState(() => _errorMsg = '해시태그는 최대 3개까지 추가할 수 있어요.');
                _ctrl.clear();
                return;
              }
              _addParsedHashtags(value);
            }
          }, // 타이핑 중 매번 반응
          textInputAction: TextInputAction.done,
          cursorColor: MColors.white,
          decoration: InputDecoration(
            hintText: '해시태그 (${_savedTagList.length}/3)',
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
        ),

        // 에러 메세지
        Padding(
          padding: EdgeInsets.symmetric(vertical: MSizes.gapXS),
          child: Row(
            children: [
              if (_errorMsg != null) ...[
                Text(_errorMsg!, style: MText.label3(color: MColors.error)),
              ],
            ],
          ),
        ),

        // 해시태그 칩 row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollCtrl,
          child: Row(
            children: _savedTagList.map((tag) {
              return Padding(
                padding: EdgeInsets.only(right: MSizes.gapS),
                child: Chip(
                  label: Text(
                    '#$tag',
                    style: MText.label2Regular(color: MColors.primaryStrong),
                  ),
                  padding: EdgeInsets.zero,
                  backgroundColor: MColors.transparent,
                  labelPadding: EdgeInsets.only(left: MSizes.gapS, right: 0),
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -2,
                  ),
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // 위젯 크기에 맞춰 터치 영역 축소
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MSizes.radiusM),
                    side: BorderSide(color: MColors.primaryStrong),
                  ),
                  deleteIcon: Icon(
                    Icons.close,
                    size: MSizes.fontM,
                    color: MColors.primaryStrong,
                  ),
                  onDeleted: () {
                    setState(() {
                      _savedTagList.remove(tag);
                      _errorMsg = null;
                    });

                    fm.hashtagList(List.of(_savedTagList));
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
