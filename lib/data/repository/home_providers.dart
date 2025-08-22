import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/home_feed.dart';
import 'package:laviu_flutter/data/repository/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

/// 홈 피드: 실서버에서 조회
/// - ref.refresh(homeFeedProvider.future)로 리프레시 가능
/// - ref.invalidate(homeFeedProvider)로 무효화 후 재조회 가능
final homeFeedProvider = FutureProvider.autoDispose<HomeFeed>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  final feed = await repo.fetchHomeFeed();
  return feed;
});
