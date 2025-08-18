enum StreamStatus {
  PENDING("대기중"),
  LIVE("방송중"),
  ENDED("종료됨");

  final String label; // 한글 라벨

  const StreamStatus(this.label);

  // 서버에서 받은 값 -> enum으로 변환
  static StreamStatus fromValue(String? value) {
    switch (value) {
      case "PENDING":
        return StreamStatus.PENDING;
      case "LIVE":
        return StreamStatus.LIVE;
      case "ENDED":
        return StreamStatus.ENDED;
      default:
        return StreamStatus.ENDED; // 기본값 (안 주는 경우가 없더라도 대비)
    }
  }

  // enum -> 서버에 주는 값
  String get value => name; // "PENDING" | "LIVE" | "ENDED"

  // 한글 라벨 볼 때 사용
  @override
  String toString() => label;
}
