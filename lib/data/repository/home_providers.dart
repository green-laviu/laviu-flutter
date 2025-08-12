import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/home_feed.dart';
import 'package:laviu_flutter/data/repository/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

final homeFeedProvider = FutureProvider<HomeFeed>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.fetchHomeFeedMock();
});
