import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/home_feed.dart';
import 'package:laviu_flutter/data/repository/home_repository.dart';

// (선택) 토큰을 프로바이더로 빼고 싶다면 이렇게:
// final authTokenProvider = Provider<String>((_) => '여기에_임시_토큰_문자열');

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  // 토큰을 외부에서 주입하고 싶다면:
  // final token = ref.watch(authTokenProvider);
  // return HomeRepository(token: token);

  return HomeRepository(); // 지금은 내부 기본 토큰 사용
});

final homeFeedProvider = FutureProvider<HomeFeed>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchHomeFeed(); // ← Mock 제거, 실제 호출
});
