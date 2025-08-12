import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laviu_flutter/data/model/following.dart';
import 'package:laviu_flutter/data/repository/following_repository.dart';

final followingRepositoryProvider = Provider<FollowingRepository>((ref) {
  return FollowingRepository();
});

final followingFeedProvider = FutureProvider<FollowingFeed>((ref) async {
  final repo = ref.watch(followingRepositoryProvider);
  return repo.fetchMock();
});
