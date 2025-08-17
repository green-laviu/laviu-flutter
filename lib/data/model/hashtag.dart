class Hashtag {
  final int? hashtagId;
  final String hashtagName;

  Hashtag({
    this.hashtagId,
    required this.hashtagName,
  });

  factory Hashtag.fromMap(Map<String, dynamic> map) {
    return Hashtag(
      hashtagId: map['hashtagId'] as int?,
      hashtagName: map['hashtagName'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hashtagId': hashtagId,
      'hashtagName': hashtagName,
    };
  }
}
