import 'package:flutter/material.dart';
import 'package:laviu_flutter/_core/style/m_colors.dart';
import 'package:laviu_flutter/_core/style/m_sizes.dart';
import 'package:laviu_flutter/_core/style/m_text.dart';
import 'package:laviu_flutter/_core/utils/m_util.dart';
import 'package:laviu_flutter/ui/widgets/m_dialog.dart';

class LiveStreamTagDialog extends StatefulWidget {
  final List<String> initialTags;

  const LiveStreamTagDialog({
    super.key,
    this.initialTags = const ['해시', '태그', '테스트'],
  });

  @override
  State<LiveStreamTagDialog> createState() => _LiveStreamTagDialogState();
}

class _LiveStreamTagDialogState extends State<LiveStreamTagDialog> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _scrollCtrl = ScrollController();
  final List<String> _savedTagList = [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    // 기존 태그
    for (final tag in widget.initialTags) {
      final normalizedTag = normalizeHashtag(tag);
      if (normalizedTag == null) continue;
      if (_savedTagList.length >= 3) break;
      if (!isDuplicateTagIgnoreCase(_savedTagList, normalizedTag)) {
        _savedTagList.add(normalizedTag);
      }
    }
  }

  void _addParsedHashtags(String tag) {
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
      });

      // 해시태그 추가 후 스크롤을 맨 오른쪽으로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: MSizes.animDurationFast,
          curve: Curves.easeOut,
        );
      });
    }
    _ctrl.clear();
    _focus.requestFocus();
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
    return MDialog(
      title: '방송 태그',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: MColors.white,
              borderRadius: BorderRadius.circular(MSizes.radiusM),
              border: Border.all(color: MColors.lineNormal),
            ),
            padding: EdgeInsets.symmetric(horizontal: MSizes.gapM),
            height: 44,
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: _ctrl,
              focusNode: _focus,
              onSubmitted: (value) {
                if (value.trim().isEmpty) return;
                if (_savedTagList.length >= 3) {
                  setState(() => _errorMsg = '해시태그는 최대 3개까지 추가할 수 있어요.');
                  _ctrl.clear();
                  return;
                }
                _addParsedHashtags(value);
              },
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
              },
              textInputAction: TextInputAction.done,
              cursorColor: MColors.textNeutral,
              decoration: InputDecoration(
                hintText: '해시태그 (${_savedTagList.length}/3)',
                hintStyle: TextStyle(
                  fontSize: MSizes.fontM,
                  fontWeight: FontWeight.w700,
                  color: MColors.textAlternative,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(
                fontSize: MSizes.fontM,
                fontWeight: FontWeight.w700,
                color: MColors.textNeutral,
              ),
            ),
          ),

          // 에러 메세지
          Padding(
            padding: EdgeInsets.symmetric(vertical: MSizes.gapS),
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
                    label: Text('#$tag', style: MText.label2Regular(color: MColors.primaryStrong)),
                    padding: EdgeInsets.zero,
                    backgroundColor: MColors.transparent,
                    labelPadding: EdgeInsets.only(left: MSizes.gapS, right: 0),
                    visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 위젯 크기에 맞춰 터치 영역 축소
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(MSizes.radiusM),
                      side: BorderSide(color: MColors.primaryStrong),
                    ),
                    deleteIcon: Icon(Icons.close, size: MSizes.fontM, color: MColors.primaryStrong),
                    onDeleted: () {
                      setState(() {
                        _savedTagList.remove(tag);
                        _errorMsg = null;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      primaryText: '확인',
      primaryColor: MColors.primaryDanger,
      onPrimaryTap: () {
        // 해시태그 최종 수정 완료 로직
      },
      secondaryText: '취소',
      onSecondaryTap: () {
        Navigator.pop(context);
      },
    );
  }
}
