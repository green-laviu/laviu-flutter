class Participant {
  final String nickname;
  final String emailId; // email의 @ 앞부분
  final int userId;
  final DateTime connectedAt; // ISO-8601

  const Participant({
    required this.nickname,
    required this.emailId,
    required this.userId,
    required this.connectedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> j) {
    return Participant(
      nickname: j['nickname'] as String,
      emailId: j['emailId'] as String,
      userId: j['userId'] as int,
      connectedAt: DateTime.parse(j['connectedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'emailId': emailId,
    'userId': userId,
    'connectedAt': connectedAt.toIso8601String(),
  };
}
