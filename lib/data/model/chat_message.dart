class ChatMessage {
  final int authorId;
  final String authorNickname;
  final String emailId; // email의 @ 앞부분
  final bool isStreamer;
  final String content;
  final DateTime timestamp; // ISO-8601 or epoch(ms) 모두 허용

  const ChatMessage({
    required this.authorId,
    required this.authorNickname,
    required this.emailId,
    required this.isStreamer,
    required this.content,
    required this.timestamp,
  });

  // ---- safe converters ----
  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static String _toStr(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  static bool _toBool(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase();
      return s == 'true' || s == '1' || s == 'y' || s == 'yes';
    }
    return fallback;
  }

  static DateTime _toDateTime(dynamic v) {
    if (v is int) {
      // epoch millis 로 오는 경우
      return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
    }
    if (v is String) {
      // ISO-8601 혹은 epoch 문자열
      final asInt = int.tryParse(v);
      if (asInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          asInt,
          isUtc: true,
        ).toLocal();
      }
      return DateTime.tryParse(v)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      authorId: _toInt(data['authorId']),
      authorNickname: _toStr(data['authorNickname']),
      emailId: _toStr(data['emailId']),
      isStreamer: _toBool(data['isStreamer']), // null/문자/숫자 모두 처리
      content: _toStr(data['content']),
      timestamp: _toDateTime(data['timestamp']),
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

  String get dedupKey => '$authorId|${timestamp.toIso8601String()}|$content';
}
