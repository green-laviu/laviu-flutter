/// 태그 목록 파싱
///
/// 붙여넣기·예외 입력 등을 고려해 한 번 더 전처리
///
/// - 쉼표/공백 기준으로 분리
/// - 양끝 공백 제거
/// - 빈 문자열 제외
/// Returns: 전처리된 태그 문자열 리스트
List<String> parseTagList(String tag) {
  return tag
      .split(RegExp(r'[,\s]+')) // 쉼표/공백 기준 분리
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty) // 빈 문자열 제거
      .toList();
}

/// 해시태그 입력 정규화
///
/// - 양끝 공백 제거
/// - # 제거
/// - 내부 공백 제거
/// - 결과가 비면 null
String? normalizeHashtag(String tagContent) {
  if (tagContent.isEmpty) return null;
  String tag = tagContent.trim(); // 양끝 공백 제거
  tag = tag.replaceFirst(RegExp(r'^\s*#+'), '').trim(); // 앞쪽 # 전체 제거 (내부 #은 제거 X)
  tag = tag.replaceAll(RegExp(r'\s+'), ''); // 내부 공백 전체 제거
  return tag.isEmpty ? null : tag;
}

/// 허용 문자/최대 길이 검증
bool isValidTag(String tag, {int maxLength = 20, RegExp? pattern}) {
  if (tag.isEmpty || tag.length > maxLength) return false;
  final p = pattern ?? RegExp(r'^[ㄱ-ㅎ가-힣a-zA-Z0-9_-]+$');
  return p.hasMatch(tag);
}

/// 중복 검사
///
/// - 비교 시 영어는 대소문자를 무시
/// - 한글/숫자는 원래 형태 그대로 비교됨
/// - 화면상에서는 원래 입력한 대소문자 유지
/// Returns: 중복이면 true, 아니면 false
bool isDuplicateTagIgnoreCase(List<String> tagList, String tag) {
  final lower = tag.toLowerCase();
  return tagList.any((e) => e.toLowerCase() == lower);
}

/// 이메일 주소에서 @앞 아이디 추출
String extractEmailId(String email) {
  if (email.isEmpty) return '';
  final parts = email.split('@');
  return parts.isNotEmpty ? parts.first : '';
}
