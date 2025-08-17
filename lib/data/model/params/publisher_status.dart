// 퍼블리셔의 로컬 상태 (클라이언트 단에서만 사용)
enum PublisherStatus {
  idle, // 초기화 전
  previewing, // 카메라 프리뷰 중
  connecting, // RTMP 서버 연결 중
  live, // 송출 중
  stopped, // 송출 종료
  error, // 에러 발생
}
