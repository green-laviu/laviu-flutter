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

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      authorId: data['authorId'] as int,
      authorNickname: data['authorNickname'] as String,
      emailId: data['emailId'] as String,
      isStreamer: data['isStreamer'] as bool,
      content: data['content'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
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
