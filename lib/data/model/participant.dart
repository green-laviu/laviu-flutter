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

  factory Participant.fromMap(Map<String, dynamic> data) {
    return Participant(
      nickname: data['nickname'] as String,
      emailId: data['emailId'] as String,
      userId: data['userId'] as int,
      connectedAt: DateTime.parse(data['connectedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'nickname': nickname,
    'emailId': emailId,
    'userId': userId,
    'connectedAt': connectedAt.toIso8601String(),
  };
}
