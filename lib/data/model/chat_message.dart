class ChatMessage {
  final int authorId;
  final String authorNickname;
  final String emailId; // email의 @ 앞부분
  final bool isStreamer;
  final String content;
  final DateTime timestamp; // ISO-8601 문자열을 DateTime으로 파싱

  const ChatMessage({
    required this.authorId,
    required this.authorNickname,
    required this.emailId,
    required this.isStreamer,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    return ChatMessage(
      authorId: j['authorId'] as int,
      authorNickname: j['authorNickname'] as String,
      emailId: j['emailId'] as String,
      isStreamer: j['isStreamer'] as bool,
      content: j['content'] as String,
      timestamp: DateTime.parse(j['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'authorId': authorId,
    'authorNickname': authorNickname,
    'emailId': emailId,
    'isStreamer': isStreamer,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  /// 중복 판단용 키 (id가 없으므로 조합키 사용)
  String get dedupKey => '$authorId|${timestamp.toIso8601String()}|$content';
}
